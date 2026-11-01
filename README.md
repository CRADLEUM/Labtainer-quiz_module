# Labtainer Quiz Module

This package extends the Labtainer `quiz` command for a Labtainer installation on your own VM.

It adds:

- Multiple choice questions, which are graded
- Survey questions, which are not graded
- A saved record of each student's answers
- The saved answers in the `.lab` results file created by `stoplab`

## Install

Run these commands on the VM, as the user who runs Labtainer:

```bash
tar xzf labtainer-quiz.tar.gz
cd labtainer-quiz
./install.sh
```

The installer finds Labtainer through `LABTAINER_DIR`, or at `~/labtainer/trunk`. It backs up the two files it changes.

To remove the module and restore those files:

```bash
./install.sh --uninstall
```

Run `./install.sh` again after each `update-labtainer.sh`. An update replaces the changed files when its release includes a newer copy, and the installer applies the module again. If nothing was replaced, running it changes nothing.

## Take a quiz

Open the terminal you use to start labs, and go to the `labtainer-student` directory:

```bash
cd ~/labtainer/labtainer-student
```

Start the quiz for the running lab:

```bash
quiz
```

To take the quiz of a lab that is not running:

```bash
quiz -l iptables2
```

If a lab has more than one quiz, add its name:

```bash
quiz -l dns -q post
```

## Add a quiz to a lab

A quiz belongs to its lab. Add a file with the `.quiz` extension to the lab's `config` directory:

```text
labs/<lab>/config/<name>.quiz
```

You do not need to rebuild the lab.

Each question is one comma-separated entry. An entry continues on the next line if the line ends with a comma or a backslash. Lines that start with `#` are comments.

### Question types

**Preface** shows text and asks nothing:

```text
ID, Preface, "Text to display"
```

**TrueFalse** is graded:

```text
ID, TrueFalse, "Question", answer, "Right message", "Wrong message", prerequisite
```

- `answer` is `T` or `F`.
- `prerequisite` is optional.

**MultipleChoice** is graded:

```text
ID, MultipleChoice, "Question", answer, "Right message", "Wrong message", prerequisite, "Option A", "Option B", "Option C"
```

- `answer` is the letter of the correct option.
- Options are lettered in order, starting from A.
- A question needs at least two options.
- Use `""` for a message or prerequisite that you do not need.

**Survey** is not graded:

```text
ID, Survey, "Question", prerequisite, "Option A", "Option B"
ID, Survey, "Question", prerequisite
```

With options, the student selects one. Without options, the student types an answer.

A `prerequisite` is the ID of another question. The question is asked only if the student answered that other question incorrectly.

### Example

```text
0, Preface, "This quiz helps you prepare for the lab."
1, MultipleChoice, "Which port does telnet use by default?", B,
   "That is correct.", "Telnet uses port 23.", "",
   "22", "23", "80", "443"
2, TrueFalse, "Telnet traffic is sent as plain text.", T, "", ""
3, Survey, "How difficult was this lab?", "", "Easy", "Medium", "Hard"
4, Survey, "What would you improve?", ""
```

## Saved answers

Answers are saved when the student completes a quiz:

```text
labtainer-student/.tmp/<lab>/<quiz>.quiz.json
```

Each attempt is added to the file with its time. For each question, the file records the student's answer and whether it was correct. `correct` is `null` for survey questions.

`stoplab` adds these files to the `.lab` results file. A quiz completed after `stoplab` is added the next time the lab is stopped.

## Limitations

- `gradelab` does not display quiz answers. To read them, open the `.lab` file as a zip archive.
- Correct answers are stored as plain text in the `.quiz` file, and students can read them.
- Students can edit their saved answers before running `stoplab`. Do not use these quizzes for assessment that needs protection from cheating.
- An attempt that is ended with Ctrl+C is not saved.
