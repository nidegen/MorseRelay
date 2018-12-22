//
//  Timer.hpp
//  MorseRelay
//
//  Created by Nicolas Degen on 22.12.18.
//  Copyright © 2018 nide. All rights reserved.
//

// Source from https://codereview.stackexchange.com/questions/40473/portable-periodic-one-shot-timer-implementation

#ifndef TIMER_H_
#define TIMER_H_

#include <algorithm>
#include <chrono>
#include <condition_variable>
#include <cstdint>
#include <functional>
#include <mutex>
#include <set>
#include <thread>
#include <unordered_map>

class Timer {
 public:
  typedef uint64_t timer_id;
  typedef std::function<void()> handler_type;

 private:
  std::mutex sync;
  typedef std::unique_lock<std::mutex> ScopedLock;

  std::condition_variable wake_up_;

 private:
  typedef std::chrono::steady_clock Clock;
  typedef std::chrono::time_point<Clock> Timestamp;
  typedef std::chrono::milliseconds Duration;

  struct Instance {
    Instance(timer_id id = 0) : id(id), running(false) {}

    template <typename Tfunction>
    Instance(timer_id id, Timestamp next, Duration period,
             Tfunction &&handler) noexcept
        : id(id), next(next), period(period),
          handler(std::forward<Tfunction>(handler)), running(false) {}

    Instance(Instance const &r) = delete;

    Instance(Instance &&r) noexcept
        : id(r.id), next(r.next), period(r.period),
          handler(std::move(r.handler)), running(r.running) {}

    Instance &operator=(Instance const &r) = delete;

    Instance &operator=(Instance &&r) {
      if (this != &r) {
        id = r.id;
        next = r.next;
        period = r.period;
        handler = std::move(r.handler);
        running = r.running;
      }
      return *this;
    }

    timer_id id;
    Timestamp next;
    Duration period;
    handler_type handler;
    bool running;
  };

  typedef std::unordered_map<timer_id, Instance> InstanceMap;
  timer_id next_id_;
  InstanceMap active;

  // Comparison functor to sort the timer "queue" by Instance::next
  struct NextActiveComparator {
    bool operator()(const Instance &a, const Instance &b) const {
      return a.next < b.next;
    }
  };
  NextActiveComparator comparator;

  // Queue is a set of references to Instance objects, sorted by next
  typedef std::reference_wrapper<Instance> QueueValue;
  typedef std::multiset<QueueValue, NextActiveComparator> Queue;
  Queue queue;

  // Thread and exit flag
  std::thread worker;
  bool done_;
  void threadStart();

 public:
  Timer();
  ~Timer();
  Timer(Timer const &r) : next_id_(1), queue(comparator), done_(false) {
    ScopedLock lock(sync);
    worker = std::thread(std::bind(&Timer::threadStart, this));
  };
  
  Timer &operator=(Timer const &r) {
    // terrible hack doing nothing but allowing to compile;
    next_id_ = r.next_id_;
    queue = r.queue;
    done_ = r.done_;
    ScopedLock lock(sync);
    worker = std::thread(std::bind(&Timer::threadStart, this));
    return *this;
  };

  timer_id create(uint64_t when, uint64_t period, const handler_type &handler);
  timer_id create(uint64_t when, uint64_t period, handler_type &&handler);

 private:
  timer_id createImpl(Instance &&item);

public:
  bool destroy(timer_id id);

  bool exists(timer_id id);
};

#endif // TIMER_H_
