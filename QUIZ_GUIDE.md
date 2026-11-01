# Labtainer Quiz Guide

**English** | [Türkçe](QUIZ_GUIDE.tr.md)

How lab developers and instructors add quizzes, run them, collect the answers, and install the VM package.

## Contents

- [Overview](#overview)
- [Installation (VM package)](#installation-vm-package)
- [What happens at each update](#what-happens-at-each-update)
- [Add a quiz to a lab](#add-a-quiz-to-a-lab)
- [More than one quiz in a lab](#more-than-one-quiz-in-a-lab)
- [File format](#file-format)
- [Question types](#question-types)
- [Prerequisites](#prerequisites)
- [Take a quiz](#take-a-quiz)
- [Saved answers](#saved-answers)
- [Instructor tasks](#instructor-tasks)
- [Multi-user server](#multi-user-server)
- [Error messages](#error-messages)
- [Limitations](#limitations)

## Overview

A quiz is a plain text file in a lab's own `config` directory. It needs no separate package and no image rebuild. As soon as the file is in the lab, the `quiz` command finds it.

A quiz runs in the student's Linux terminal, not inside the lab containers. A student can therefore open it while the lab is not running.

| Feature | Original Labtainer | With the quiz module |
|---|---|---|
| Information text (`Preface`) | Yes | Yes |
| True or false (`TrueFalse`) | Yes | Yes |
| Multiple choice (`MultipleChoice`) | No | Yes, graded |
| Survey (`Survey`) | No | Yes, not graded |
| Saved answers | No | Every attempt is saved |
| Answers in the `.lab` file | No | Added by `stoplab` |

### Who does what

| Role | Task | Needs the module |
|---|---|---|
| Lab developer | Writes the `.quiz` file, adds it to the lab, and tests it to the end | Yes |
| Student | Takes the quiz, stops the lab with `stoplab`, and sends the `.lab` file | Yes, for the new types and saved answers |
| Instructor | Collects `.lab` files, grades them, and reads the answers | No, `gradelab` works unchanged |

## Installation (VM package)

The package is for people who run Labtainer on their own VM. The file is `labtainer-quiz.tar.gz`.

1. Copy the package to the VM. A shared folder, `scp`, or a browser download all work.
2. If a lab is running, stop it with `stoplab`.
3. Run these commands as the user who runs Labtainer. Do not use `sudo`.

```bash
tar xzf labtainer-quiz.tar.gz
cd labtainer-quiz
./install.sh
```

A successful install prints `Quiz module installed in ...`.

The installer finds Labtainer through `LABTAINER_DIR`, or at `~/labtainer/trunk`. For another location:

```bash
LABTAINER_DIR=/other/path/labtainer/trunk ./install.sh
```

### What is in the package

| File | Purpose |
|---|---|
| `install.sh` | Installs, reapplies, and removes the module |
| `quiz` | The new quiz program, which replaces Labtainer's `quiz` file |
| `labutils_quiz.patch` | Adds three lines to `labutils.py` that put answers in the `.lab` file |
| `README.md` | Short usage notes in English |

### What changes on the system

Only two files change, both in `trunk/scripts/labtainer-student/bin`: `quiz` and `labutils.py`. Their backups are in `.quiz_backup` in the same directory.

To confirm the install, run this command. The result should be `1`:

```bash
grep -c 'quiz.json' ~/labtainer/trunk/scripts/labtainer-student/bin/labutils.py
```

If the `patch` command is missing, the installer stops, prints the install command, and leaves the files unchanged:

```bash
sudo apt-get install patch
```

### Remove the module

Run this from the package directory, so keep that directory.

```bash
./install.sh --uninstall
```

The original files return. Saved answers and `.quiz` files stay. The original program silently skips `MultipleChoice` and `Survey` questions.

## What happens at each update

> [!IMPORTANT]
> Run `./install.sh` from the package directory after every `update-labtainer.sh`. If nothing changed, it does no harm.

```bash
cd ~/labtainer/labtainer-student
update-labtainer.sh
cd ~/labtainer-quiz
./install.sh
```

`update-labtainer.sh` extracts the new release with `tar --keep-newer-files`. It skips a file on disk that is newer than the release copy, and replaces one that is older. `install.sh` keeps the original dates of the files it changes, so an update still picks up newer files from a release.

| During the update | Result | What to do |
|---|---|---|
| The release has a newer `labutils.py` or `quiz` | The new copy replaces it, and that part of the module is gone | `./install.sh` applies it again |
| The release did not change these two files | The module stays in place | `./install.sh` changes nothing |
| A `.quiz` file you added under your own name | It stays | Nothing |
| You edited a `.quiz` file that ships with Labtainer | It stays if your file is newer than the release copy, otherwise it is overwritten | Keep your changes in a separate file with your own name |
| Saved answers and `.lab` files | Not touched | Nothing |

> [!WARNING]
> If you skip `./install.sh` after an update that replaced `quiz`, the new types stop working. If it replaced `labutils.py`, quizzes still work, but answers no longer reach the `.lab` file, and no error is shown.

### If the patch is refused

This message means the new Labtainer release changed the code that the patch touches:

```text
This version of labutils.py does not accept the patch, nothing was changed.
```

No file changes, and Labtainer runs as the original. You then need a package that matches the new release.

### A new package version

- If a new package changes only the `quiz` program, extract it and run `./install.sh`.
- If `labutils_quiz.patch` also changed, first run `./install.sh --uninstall` from the old package directory, then run `./install.sh` from the new one.

## Add a quiz to a lab

1. Create a file with the `.quiz` extension in the lab's `config` directory. The file name is the quiz name. Do not use spaces.
2. Write the questions using the [file format](#file-format).
3. Test the quiz by completing it to the end.
4. State in the lab manual when to take the quiz and which command to use.

```text
~/labtainer/trunk/labs/telnetlab/config/telnet.quiz
```

A short starting example:

```text
# telnetlab preparation quiz
0, Preface, "This quiz helps you check yourself before the lab."
1, MultipleChoice, "Which port does telnet use by default?", B,
   "That is correct.", "Telnet uses port 23.", "",
   "22", "23", "80", "443"
2, TrueFalse, "Telnet traffic is sent as plain text.", T, "", ""
3, Survey, "How difficult was this lab?", "", "Easy", "Medium", "Hard"
4, Survey, "What would you improve?", ""
```

> [!IMPORTANT]
> The file is read as the questions are asked. A broken question stops the quiz only when it is reached, and that attempt is not saved. To see prerequisite questions, also take the quiz with wrong answers.

Working examples are in the `config` directories of the `db-access`, `dmz-lab`, `dns`, and `iptables2` labs.

## More than one quiz in a lab

Put more than one `.quiz` file in the same `config` directory. There is no limit on the number.

```text
labs/telnetlab/config/pre.quiz
labs/telnetlab/config/post.quiz
labs/telnetlab/config/survey.quiz
```

The plain `quiz` command then asks no questions and lists the choices:

```text
Multiple quizzes for this lab.  Pick one with the -q option: post pre survey
```

The student gives the name without the `.quiz` extension:

```bash
quiz -q pre
```

Each quiz has its own saved file (`pre.quiz.json`, `post.quiz.json`), and `stoplab` adds all of them to the `.lab` file.

Quizzes cannot depend on each other: a prerequisite sees only questions in its own file, and the program does not enforce an order. State the order in the lab manual.

## File format

Each question is one comma-separated entry. The first two fields are always the ID and the type.

| Rule | Details |
|---|---|
| Encoding | UTF-8 without a BOM. Non-ASCII text is supported. A BOM breaks the first line, so check this if you edit in Windows Notepad. CRLF line endings are fine. |
| Comments | A line that starts with `#` is skipped, even in the middle of a multi-line question. |
| Continuing a question | If a line ends with `,` the question continues on the next line. If a line ends with `\` the text joins the next line, which lets you split long text. |
| Blank lines | Do not use them. Between questions, one prints `bad line?`. Inside a multi-line question, one cuts the question short and the quiz stops. |
| Text | Put text in double quotes. A comma inside quotes is not a separator. |
| Quotes in text | Double them: `"What does ""ls -l"" do?"` |
| New line in text | Write `\n`. For a real backslash, write `\\`. |
| Empty fields | Write `""`. The number of fields matters, so an empty field cannot be left out. |
| Type name | Case does not matter: `TrueFalse`, `truefalse`. |
| ID | Must be unique in the file. It can be a number or text, and is saved in lowercase. |
| Long lines | Wrapped automatically on screen. |

## Question types

### Preface: information text

```text
ID, Preface, "Text to display"
```

Shows text and asks for nothing. It is not saved or counted. Place it before questions to give context.

### TrueFalse: true or false

```text
ID, TrueFalse, "Question", answer, "Right message", "Wrong message", prerequisite
```

| Field | Required | Value |
|---|---|---|
| answer | Yes | `T` or `F` |
| Right message | Yes | Shown for a right answer, or `""` |
| Wrong message | Yes | Shown for a wrong answer, or `""` |
| prerequisite | No | The ID of another question |

The student must type `T` or `F`, in either case. `true`, an empty answer, or anything else is not asked again and counts as wrong. This is how the original program behaves.

```text
3, TrueFalse, "nmap can find open ports.", T, "", ""
```

### MultipleChoice: multiple choice

```text
ID, MultipleChoice, "Question", answer, "Right message", "Wrong message", prerequisite, "Option A", "Option B", ...
```

| Field | Required | Value |
|---|---|---|
| answer | Yes | The letter of the correct option, in either case |
| Right and wrong messages | Yes | Text or `""` |
| prerequisite | Yes | An ID, or `""` if there is none |
| options | 2 to 26 | Lettered A, B, C automatically, in order |

> [!WARNING]
> If you leave out the `""` for the prerequisite, the first option is read as the prerequisite, and the question is skipped with no error. The correct order is `"Wrong message", "", "Option A"`.

An invalid entry asks the question again and does not count as wrong. If the answer letter is not one of the options, the quiz stops when it reaches that question.

### Survey: survey

```text
ID, Survey, "Question", prerequisite, "Option A", "Option B"
ID, Survey, "Question", prerequisite
```

With options, the student selects one. Without options, the student types free text and may leave it empty. The prerequisite field is required, so write `""` if there is none.

A survey has no correct answer, shows no feedback, and is not part of the wrong answer count. If a quiz contains only surveys, it ends with `Your responses have been recorded.`

## Prerequisites

A prerequisite asks a question only if the student answered another question incorrectly. Use it to reinforce a missed concept, or to ask why the student got it wrong.

```text
1, TrueFalse, "Telnet is encrypted.", F, "", ""
2, MultipleChoice, "Which one provides an encrypted remote session?", B, "", "", 1, "telnet", "ssh"
3, Survey, "Why did you answer incorrectly?", 1, "I did not know", "I was not careful"
```

- The prerequisite question must come earlier in the file. If it comes later, this question is never asked.
- IDs are not case-sensitive.
- Surveys and Prefaces are never wrong, so a question that depends on one is never asked.
- A skipped question is not saved or counted.
- All three question types accept a prerequisite.

## Take a quiz

Run a quiz in the terminal you use to start labs, from the `labtainer-student` directory. From any other directory it prints `The lab has no quizzes`.

```bash
cd ~/labtainer/labtainer-student
```

| Situation | Command |
|---|---|
| Lab running, one quiz | `quiz` |
| Lab running, more than one quiz | `quiz -q pre` |
| Lab not running | `quiz -l iptables2` |
| Lab not running, more than one quiz | `quiz -l dns -q post` |
| More than one lab running | `quiz -l telnetlab` |
| Help | `quiz -h` |

| Question | What the student types |
|---|---|
| TrueFalse | `T` or `F`, then Enter |
| MultipleChoice | The option letter, then Enter |
| Survey with options | The option letter, then Enter |
| Survey without options | Free text, then Enter |

At the end, the quiz prints the wrong answer count or `You answered all questions correctly.` Students can repeat a quiz as often as they like, and each attempt is saved separately. `Ctrl+C` leaves the quiz, and that attempt is not saved.

## Saved answers

When a quiz is completed, the answers are added to this file. Earlier attempts stay.

```text
labtainer-student/.tmp/<lab>/<quiz>.quiz.json
```

```json
[
    {
        "time": "2026-10-31 20:35:54.837782",
        "responses": [
            {
                "id": "1",
                "type": "multiplechoice",
                "question": "Which port does telnet use by default?",
                "response": "A",
                "response_text": "22",
                "correct": false
            }
        ]
    }
]
```

| Field | Meaning |
|---|---|
| `time` | When the attempt ended |
| `id`, `type`, `question` | The question's ID, type, and text |
| `response` | The letter typed. `null` for a free text survey |
| `response_text` | The selected option's text, or the typed text. `null` for TrueFalse |
| `correct` | `true` or `false`. `null` for a survey |

### Packaging

`stoplab` adds these files to the `.lab` file in `~/labtainer_xfer/<lab>/`. A quiz completed after `stoplab` is added the next time the lab stops, so after a final quiz, start and stop the lab once more.

`redo` (`labtainer -r`) keeps the answers. There is one exception: when a lab has a `read_pre.txt` file, answering anything other than `y` at its `Continue? (y/n)` prompt on first start makes Labtainer delete `.tmp/<lab>`.

## Instructor tasks

### Deliver a quiz to students

- **By hand:** Have each student copy the `.quiz` file to `~/labtainer/trunk/labs/<lab>/config/`.
- **IModule:** Labtainer's method for instructor content. Publish a tar file with paths relative to the `labs` directory, such as `telnetlab/config/pre.quiz`. Students run `imodule <url>`. The files refresh at each `update-labtainer.sh` or `imodule -u`.

Students must also install the quiz module. An IModule writes only to the `labs` directory.

### Collect the answers

1. Students run `stoplab` and send the `.lab` file from `~/labtainer_xfer/<lab>/`.
2. Put the files in your own `~/labtainer_xfer/<lab>/` directory.
3. To grade the lab, run `gradelab <lab>` from the `labtainer-instructor` directory. Quiz files do not affect grading.

`gradelab` does not display quiz answers, so read them from the `.lab` file, which is a zip archive:

```bash
python3 -m zipfile -l student_at_umich.edu.telnetlab.lab
python3 -m zipfile -e student_at_umich.edu.telnetlab.lab answers/
```

### Combine all students in one table

Save this code as `quiz_report.py`. It reads all `.lab` files of a lab and writes a CSV with one row per answer.

```python
import csv, glob, json, os, sys, zipfile

lab = sys.argv[1]
writer = csv.writer(sys.stdout)
writer.writerow(['student', 'quiz', 'attempt', 'time', 'id', 'type', 'response', 'response_text', 'correct'])
for path in sorted(glob.glob(os.path.expanduser('~/labtainer_xfer/%s/*.lab' % lab))):
    student = os.path.basename(path).rsplit('.', 2)[0]
    with zipfile.ZipFile(path) as z:
        for name in z.namelist():
            if name.endswith('.quiz.json'):
                for number, attempt in enumerate(json.loads(z.read(name)), 1):
                    for r in attempt['responses']:
                        writer.writerow([student, name[:-len('.quiz.json')], number, attempt['time'], r['id'],
                                         r['type'], r['response'], r['response_text'], r['correct']])
```

```bash
python3 quiz_report.py telnetlab > telnetlab_quiz.csv
```

## Multi-user server

The multi-user Labtainer patch already includes the quiz module, so `install.sh` is not used there. `setup.sh` applies it to `/home/student/labtainer`, and student copies are created from that directory.

- New users receive the module through `open.sh`. Existing users receive it when `setup.sh` runs again.
- Each student has a private Labtainer copy, so new `.quiz` files must go into existing students' copies as well as `/home/student/labtainer`.
- The commands are the same. Each student sees only their own lab, and answers stay separate.

## Error messages

| Message | Cause | Fix |
|---|---|---|
| `The lab has no quizzes` | The lab has no `.quiz` file, the lab name is wrong, or you are in the wrong directory | Go to `labtainer-student` and check the name |
| `No labs are currently running...` | No lab is running | Use `quiz -l <lab>` |
| `multiple labs running...` | More than one lab is open | Use `quiz -l <lab>` |
| `Multiple quizzes for this lab...` | The lab has more than one quiz | Select one with `-q` |
| `Given quiz ... not one of the quizzes` | The `-q` name is wrong | Use a name from the message |
| `Not enough elements in this question` | A field is missing, or a multi-line question has a blank line | Count the fields and add `""` |
| `Answer X of question N is not one of its options` | The answer letter is not among the options | Fix the letter or the options |
| `Unknown question type ...` | The type is misspelled, and the question is skipped | Fix the type name |
| `bad line?` | A blank or broken line | Remove the line |
| A question is never asked | The `""` prerequisite is missing in a multiple choice question, or the prerequisite question was answered correctly | Check the fields |
| Answers are not in the `.lab` file | An update removed the module, or the quiz was taken after `stoplab` | Run `./install.sh`, then start and stop the lab |

## Limitations

- **Not for exams.** Correct answers are plain text in the `.quiz` file, and students can read them. Students can also edit their saved answers before `stoplab`.
- **No grade display.** `gradelab` does not show quiz results or add them to a grade.
- **One answer.** A multiple choice question cannot have more than one correct option.
- **Fixed order.** Questions and options are not shuffled or varied per student.
- **Quizzes are optional.** Starting or stopping a lab does not check whether a quiz was taken.
