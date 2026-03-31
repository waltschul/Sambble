# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Sambble is an iOS/SwiftUI Scrabble word flashcard app implementing a Leitner-style spaced repetition system. It quizzes users on anagram sets (alphagrams → valid words) sourced from the NWL23 word list (`Resources/nwl23.csv`).

## Building and Running

This is an Xcode project — build and run via Xcode. There are no CLI build commands, package managers, or test suites.

- Open `Sambble.xcodeproj` in Xcode
- The `DEBUG` flag (`Constants.DEBUG`) is set via `#if DEBUG` — in debug builds, persistence is disabled and treat probability is higher (1/2 vs 1/50)

## Architecture

### Core Data Flow

1. `QuizCache` loads all quizzes on startup (from JSON persistence or creates new ones for non-probabilistic quizzes)
2. `RootView` holds a `QuizCache` and displays `QuizView` for the selected quiz, or `InitializeView` if the quiz hasn't been started yet
3. `QuizView` owns a `QuizViewModel` which wraps a `Quiz` and handles user input (tap, swipe, keyboard, media controls)
4. `Quiz` is the core model: it holds the cardboxes and drives the spaced repetition algorithm

### Spaced Repetition System

- `Quiz` maintains `cardboxes: [[Card]]` — 10 boxes (0–9) per the Leitner system
- `CardboxAlgorithm` determines which box to pull from next based on a counter
- `CardLoader` holds the remaining unseen cards; it pops cards into box 0 to keep it filled to `cardboxZeroSize` (default 5)
- `ViewedCard` tracks the current/next card being shown, including `AnswerState` (UNCHECKED → CHECKED → EASY) and `CorrectState` (UNANSWERED / CORRECT / INCORRECT)
- On answer: CORRECT moves card to next box (or last box if EASY), INCORRECT sends it back to box 0

### Card Interaction

- First tap: reveals answer (UNCHECKED → CHECKED)
- Second tap: marks as easy / normal (Optional -- starts as normal, and taps flip the state between the two)
- Left arrow / swipe left: incorrect; right arrow / swipe right: correct
- `treatModeEnabled` on `Quiz` enables "treat" cards — random words from the harder half of the unlearned deck, interspersed as a reward
- On desktop, arrow keys replace swipes, and spacebar replaces taps
- On bluetooth mode, there is no ability to mark card as easy. The first next or previous track reveals the answer, then subsequent ones act as swipes 

### Quiz Types

Defined in `QuizID.swift`. Two modes:
- `probabilityOrder: true` (Sevens, Eights) — cards served in frequency/probability order; quiz must be explicitly started via `InitializeView`
- `probabilityOrder: false` (Twos, Threes, Fours, JKQXZ Fives, 5-Vowel Eights) — cards shuffled; quiz auto-initializes on first load

### Persistence

- Each `Quiz` serializes to a JSON file in the App Group container (`group.Sambble`)
- Serialization is custom: `Card` only encodes its `id` (alphagram string) and reconstructs `words` from `CardLoader` during decode. The `CardLoader` is passed via `decoder.userInfo[.cardLoader]`
- Saves on app background and after each card answer

### Car Mode

`SettingsStore.carMode` activates media key controls (`MediaCommandManager`) and a `SilentAudioPlayer` to keep the audio session alive. Next/previous media buttons control card advancement.

### Settings

`SettingsStore` is a singleton `ObservableObject` using `@AppStorage` for persistence. It is injected as an `@EnvironmentObject` from `SambbleApp`.
