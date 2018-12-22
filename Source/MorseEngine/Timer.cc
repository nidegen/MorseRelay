//
//  Timer.cc
//  MorseRelay
//
//  Created by Nicolas Degen on 22.12.18.
//  Copyright © 2018 nide. All rights reserved.
//

#include "Timer.h"

void Timer::threadStart() {
  ScopedLock lock(sync);

  while (!done_) {
    if (queue.empty()) {
      // Wait (forever) for work
      wake_up_.wait(lock);
    } else {
      auto firstInstance = queue.begin();
      Instance &instance = *firstInstance;
      auto now = Clock::now();
      if (now >= instance.next) {
        queue.erase(firstInstance);

        // Mark it as running to handle racing destroy
        instance.running = true;

        // Call the handler
        lock.unlock();
        instance.handler();
        lock.lock();

        if (done_) {
          break;
        } else if (!instance.running) {
          // Running was set to false, destroy was called
          // for this Instance while the callback was in progress
          // (this thread was not holding the lock during the callback)
          active.erase(instance.id);
        } else {
          instance.running = false;

          // If it is periodic, schedule a new one
          if (instance.period.count() > 0) {
            instance.next = instance.next + instance.period;
            queue.insert(instance);
          } else {
            active.erase(instance.id);
          }
        }
      } else {
        // Wait until the timer is ready or a timer creation notifies
        wake_up_.wait_until(lock, instance.next);
      }
    }
  }
}

Timer::Timer() : next_id_(1), queue(comparator), done_(false) {
  ScopedLock lock(sync);
  worker = std::thread(std::bind(&Timer::threadStart, this));
}

Timer::~Timer() {
  ScopedLock lock(sync);
  done_ = true;
  wake_up_.notify_all();
  lock.unlock();
  worker.join();
}

Timer::timer_id Timer::create(uint64_t msFromNow, uint64_t msPeriod,
                              const std::function<void()> &handler) {
  return createImpl(Instance(0, Clock::now() + Duration(msFromNow),
                             Duration(msPeriod), handler));
}

Timer::timer_id Timer::create(uint64_t msFromNow, uint64_t msPeriod,
                              std::function<void()> &&handler) {
  return createImpl(Instance(0, Clock::now() + Duration(msFromNow),
                             Duration(msPeriod), std::move(handler)));
}

Timer::timer_id Timer::createImpl(Instance &&item) {
  ScopedLock lock(sync);
  item.id = next_id_++;
  auto iter = active.emplace(item.id, std::move(item));
  queue.insert(iter.first->second);
  wake_up_.notify_all();
  return item.id;
}

bool Timer::destroy(timer_id id) {
  ScopedLock lock(sync);
  auto i = active.find(id);
  if (i == active.end())
    return false;
  else if (i->second.running) {
    // A callback is in progress for this Instance,
    // so flag it for deletion in the worker
    i->second.running = false;
  } else {
    queue.erase(std::ref(i->second));
    active.erase(i);
  }

  wake_up_.notify_all();
  return true;
}

bool Timer::exists(timer_id id) {
  ScopedLock lock(sync);
  return active.find(id) != active.end();
}
