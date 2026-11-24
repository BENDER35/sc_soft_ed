# Didactic guide (English)

This guide accompanies `sc_soft_ed`. It does not prescribe an official curriculum: it offers a **usage sequence** for the installed tools aimed at learners aged 6–16 (and adult beginners).

## 1. Pedagogical principles

| Principle | Meaning in the classroom | How this catalog applies it |
|---|---|---|
| Constructivism | Learners build meaning by exploring, not only by receiving data | GeoGebra, Step and PhET let students test hypotheses and see results |
| Constructionism (Papert) | Learning to program is learning to think | Scratch and Thonny: create artifacts, not just answer exercises |
| Scaffolding (Vygotsky) | Gradual support withdrawn as competence grows | GCompris levels; KTouch and Anki adapt difficulty |
| Spaced repetition | Reviewing at growing intervals fixes memory | Anki schedules cards by performance |
| Gamification | Challenges, immediate feedback and progress sustain motivation | GCompris, Tux Math, KAnagram, KHangMan |
| Bloom's taxonomy | Order objectives: remember → understand → apply → analyse → evaluate → create | Every session ends with "create something", not just answering |

## 2. A 45-minute session

1. **Motivation (5 min).** Trigger question: "Why does water rise in the tube?"
2. **Guided demo (8 min).** The teacher opens the tool and solves a simple case on screen.
3. **Pair exploration (15 min).** Two students, one machine; one operates, the other records hypotheses. Swap halfway.
4. **Creation challenge (12 min).** Produce an artifact: a construction, a vector drawing, an Anki card, a 10-block program.
5. **Closure and metacognition (5 min).** "What changed from your first idea?" Write it in Xournal++ or Freeplane.

## 3. Sequence by age band

- **6–8:** GCompris (mouse, keyboard, counting, sequences), Tux Paint, Tux Typing. Goal: digital literacy and basic reading fluency.
- **9–11:** Tux Math, GeoGebra, KAnagram, KHangMan, KWordQuiz, KStars. Goal: arithmetic, vocabulary and scientific observation.
- **12–14:** Scratch, Thonny, Step, KAlgebra, Kig, KGeography, Audacity. Goal: logic, modelling and expression.
- **15–16 and adults:** LibreOffice, Anki, Kiwix, Inkscape, Krita, GIMP, MuseScore, Scribus, Freeplane. Goal: autonomous production and independent study.

## 4. Four-week sample plan

| Week | Subject | Tool | Final product |
|---|---|---|---|
| 1 | Mathematics | GeoGebra + KAlgebra | Interactive parabola construction plus its table |
| 2 | Language | KWordQuiz + Anki | 20-word deck with example sentences and audio |
| 3 | Science | Step + KStars | Inclined-plane model and a week-long Moon log |
| 4 | Technology | Scratch or Thonny | Small game with scoring and restart |

## 5. Assessment

- **Formative:** observe during exploration; note wrong hypotheses and revisit them at closure.
- **Summative:** four-level rubric (initial, developing, achieved, advanced) covering correct tool use, concept explanation, evidence recording and creativity.
- **Self-assessment:** "Today I learned… / I struggled with… / Tomorrow I will try…".
- Do not grade speed: value reasoning and the ability to explain the process.

## 6. Accessibility and good practice

- Enable subtitles and system contrast before the session.
- KTouch and Tux Typing support large keyboards and alternative layouts.
- Use heterogeneous pairs; rotate the "operator" and "recorder" roles.
- Kiwix works **offline**: download the Wikipedia package in the course language.
- No personal accounts are required for basic use of any catalog tool.
- Save student work in a shared course folder, not in the pupil's profile.

## 7. Installation troubleshooting

| Symptom | Action |
|---|---|
| `sudo: command not found` | Run `./install.sh --list-stores` and use `--stores` with a user store (flatpak, brew, nix). |
| Package missing on this distro | Expected: the catalog has per-store alternative names. Try `--all-stores` or `--group all`. |
| Flatpak asks for Flathub | The script adds the remote automatically; check with `flatpak remote-list`. |
| winget cannot find an id | The script falls back to a name search; you can also use `-Stores choco,scoop`. |
| macOS without Homebrew | Install Homebrew from https://brew.sh or use `--stores macports,nix`. |

## 8. Cited resources

- Wikipedia, *Educational software*: https://en.wikipedia.org/wiki/Educational_software
- Wikipedia, *GCompris*: https://en.wikipedia.org/wiki/GCompris
- Karolčík et al. (2015), CEELTES framework: https://doi.org/10.15388/infedu.2015.14
- PhET Interactive Simulations: https://phet.colorado.edu/
- Scratch: https://scratch.mit.edu/

---

[Back to README](../README.md) · [Historia y temario (ES)](HISTORIA_Y_TEMARIO_ES.md) · [Mirror](MIRROR.md)
