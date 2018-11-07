#include "main.h"

struct loopObj {
  LoopFunc loopFunc = NULL;
  std::vector<void*> loopArray;
  using Iterator = decltype(loopArray)::iterator;
  Iterator it;
  Iterator start;
  Iterator end;

  loopObj() {}
  loopObj(LoopFunc f, void** a, unsigned int count) {
    loopFunc = f;
    loopArray = std::vector<void*>(a, a + count);
    start = loopArray.begin();
    end = loopArray.end();
  }

  void loop() {
    for (it = start; it != end; ++it) loopFunc(*it);
  }
};

std::unordered_map<unsigned int, loopObj> loopObjs;

void* createLoop(const unsigned int index, void** a, const unsigned int count, LoopFunc f) {
  return &(loopObjs[index] = loopObj(f, a, count));
}

void loopByIndex(const unsigned int index) {
  const auto& it = loopObjs.find(index);
  if (it == loopObjs.end()) return;
  it->second.loop();
}

void loopByObject(void* iobj) {
  if(!iobj) return;
  ((loopObj*)iobj)->loop();
}

// -------------------------------------------

std::vector<void*> FIELDS = {};
using FIELDS_IT = decltype(FIELDS)::iterator;
FIELDS_IT FIT;
FIELDS_IT FEND;
FIELDS_IT FSTART;
LoopFunc renderFun = NULL;

void prepare(LoopFunc f, void** a, unsigned int count) {
  renderFun = f;
  FIELDS = std::vector<void*>(a, a + count);
  FSTART = FIELDS.begin();
  FEND = FIELDS.end();
}

void loop() {
  for (FIT = FSTART; FIT != FEND; ++FIT) renderFun(*FIT);
}
