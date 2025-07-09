<!-- Improved compatibility of back to top link: See: https://github.com/othneildrew/Best-README-Template/pull/73 -->
<a id="readme-top"></a>
<!--
*** Thanks for checking out the Best-README-Template. If you have a suggestion
*** that would make this better, please fork the repo and create a pull request
*** or simply open an issue with the tag "enhancement".
*** Don't forget to give the project a star!
*** Thanks again! Now go create something AMAZING! :D
-->



<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![Unlicense License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/othneildrew/Best-README-Template">
    <img src="images/logo.png" alt="Logo" width="80" height="80">
  </a>

  <h3 align="center">Best-README-Template</h3>

  <p align="center">
    Project Laboratory IC Design TUM assignment
    &middot;
    <a href="https://github.com/henrysommerville/ICDesign/issues/new?labels=bug&template=bug-report---.md">Report Bug</a>
    &middot;
    <a href="https://github.com/henrysommerville/ICDesign/issues/new?labels=enhancement&template=feature-request---.md">Request Feature</a>
  </p>
</div>



<!-- TABLE OF CONTENTS -->
<details>
  <summary>Table of Contents</summary>
  <ol>
    <li>
      <a href="#about-the-project">About The Project</a>
    </li>
  </ol>
</details>



<!-- ABOUT THE PROJECT -->
## About The Project

# 🕒 Digital Clock System on Zynq-7000 FPGA

## 📚 Project Description

This project implements a comprehensive **Digital Clock System** on a **Zynq-7000 FPGA**, featuring five major time-related functionalities:

### 1. Time and Date Display
- Displays real-time clock and date using DCF77 signal synchronization.
- Supports user-defined date override via hardware switches.

### 2. Alarm Clock
- User-configurable alarm time.
- Alarm can be snoozed or dismissed via short or long button presses.
- Visual indicators show active alarm and ringing status.

### 3. Time Switch (NOT IMPLEMENTED)
- Enables timed on/off control (e.g., for a device or relay).
- Allows configuration of "on" and "off" times via user input.

### 4. Countdown Timer (NOT IMPLEMENTED)
- User can set a specific countdown duration.
- When countdown reaches zero, a visual alert is triggered.

### 5. Stopwatch with Lap Feature
- Supports start, pause, reset, and lap time capture.
- Lap values can be viewed and cleared by the user.

---

## ⚙️ System Design Notes
- Runs on a **10 kHz master clock**.
- All timing is driven by internally generated enables: `en_1K`, `en_100`, `en_10`, and `en_1`.
- Designed using **VHDL only**:
- Fully synchronous design with **no inferred latches**.
- Button inputs are debounced and interpreted via `*_imp` (impulse) and `*_long` (long press) signals.

---

## 🧪 Testing

A comprehensive **VHDL testbench** is provided to simulate and validate key use cases:

- Mode transitions and user interactions
- Alarm set, snooze, and disable workflow
- Stopwatch operation including lap and reset
- Countdown setup and expiration handling

---



### Top contributors:

<a href="https://github.com/othneildrew/Best-README-Template/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=othneildrew/Best-README-Template" alt="contrib.rocks image" />
</a>

<p align="right">(<a href="#readme-top">back to top</a>)</p>
