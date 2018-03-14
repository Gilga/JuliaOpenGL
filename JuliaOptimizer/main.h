#pragma once

#include <array>
#include <unordered_map>

typedef void(*LoopFunc)(void*);
typedef void(*LoopFunc2)(float*);

#define EXPORT __declspec(dllexport)

extern "C" {
	EXPORT void* createLoop(const unsigned int, void** a, const unsigned int, LoopFunc);
	EXPORT void loopByIndex(const unsigned int);
	EXPORT void loopByObject(void*);
	EXPORT void prepare(LoopFunc f, void** a, unsigned int count);
	EXPORT void loop();
};