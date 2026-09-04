<div align="center">

# OpenModelica for Process Engineers

**A learn-in-public guide series on open-source process simulation — with every model I build along the way.**

[![Guides](https://img.shields.io/badge/guides-1%20published-blue.svg)](#-guide-series)
[![Stage](https://img.shields.io/badge/stage-01%20Modelica%20Basics-informational.svg)](#-where-this-project-is-right-now)
[![Modelica](https://img.shields.io/badge/Modelica-3.2.3-9cf.svg)](https://modelica.org/)
[![OpenModelica](https://img.shields.io/badge/OpenModelica-1.27.0-orange.svg)](https://openmodelica.org/)
[![Python](https://img.shields.io/badge/Python-3.12+-3776AB.svg?logo=python&logoColor=white)](https://www.python.org/)
[![Status](https://img.shields.io/badge/status-work%20in%20progress-yellow.svg)](#-where-this-project-is-right-now)
[![License](https://img.shields.io/badge/license-BSD--3--Clause-green.svg)](LICENSE)

</div>

---

## 📖 Description

Commercial process simulators are excellent — and expensive, and closed. [OpenModelica](https://openmodelica.org/) is free, open source, and equation-based: you write the mass balance, the energy balance, the equilibrium relation, and the compiler works out how to solve them. Nothing is hidden in a black box.

This repository is **a process engineer learning that tool properly, in public**. It has two halves that grow together:

- **📘 A written guide series** in [docs/](docs/) — structured walkthroughs aimed at engineers who have never opened a Modelica file, released as versioned PDFs.
- **🧪 A companion model repository** — every model discussed in the guides, in a numbered folder, so you can open the exact file rather than retype it from a screenshot.

> [!NOTE]
> **This is an active learning journey, not a finished product.** Guide 00 is published; the rest is being written and tested. See [Where This Project Is Right Now](#-where-this-project-is-right-now) for an honest status of every stage. Everything here is for **educational use** — these are teaching models, not validated industrial ones.

### ✨ What you get today

- **A complete beginner's guide** covering what OpenModelica is, installing it on Windows/Linux/macOS, navigating OMEdit, Modelica language basics, and exporting simulation data — [available as a PDF](docs/01%20PDFs/).
- **Runnable companion models** for every worked example in that guide.
- **A screenshot-by-screenshot OMEdit walkthrough** of a first model, from blank canvas to plotted result.
- **A commitment to keep going** — the roadmap below is what is actually being worked on next, not a wish list.

---

## 📑 Table of Contents

- [Description](#-description)
- [Where This Project Is Right Now](#-where-this-project-is-right-now)
- [Guide Series](#-guide-series)
- [Installation & Setup](#️-installation--setup)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [Roadmap](#️-roadmap)
- [Contributing](#-contributing)
- [References](#-references)
- [License](#-license)
- [Author](#-author)

---

## 📍 Where This Project Is Right Now

Learning a simulation tool is a staircase, not a leap. Here is exactly which step this project is standing on — so you know what is ready to use, and what is still being built.

| Stage | Topic | Status |
| :---: | --- | --- |
| **00** | **Getting started** — what OpenModelica is, installation on Windows / Linux / macOS, OMEdit tour, verifying the install | ✅ **Published** |
| **01** | **Modelica language basics** — data types, model structure, packages, writing and simulating a first model, exporting results to CSV | ✅ **Published** |
| **02** | **Custom icons & the full OMEdit workflow** — check → translate → simulate → plot | 🟢 **Model done, guide pending** |
| **03** | **Loading external libraries** — adding a process-simulation library to OpenModelica and getting it to compile | 🚧 **In progress** |
| **04** | **Thermodynamic packages** — property methods, when each one applies, and what happens when you pick the wrong one | 📋 **Planned** |
| **05** | **Unit operations** — mixers, splitters, heaters, coolers, valves, pumps | 📋 **Planned** |
| **06** | **Separation** — flash drums, distillation and absorption columns | 📋 **Planned** |
| **07** | **Reactors** — conversion, equilibrium, CSTR, PFR | 📋 **Planned** |
| **08** | **Flowsheeting** — connecting unit operations into a full process, recycle loops, convergence | 📋 **Planned** |
| **09** | **OMPython & automation** — driving simulations from Python, toward digital twins and real-time optimisation | 💡 **Idea** |

**Legend** — ✅ Published · 🟢 Built, being written up · 🚧 In progress · 📋 Planned · 💡 Idea

> [!IMPORTANT]
> **In practical terms:** OpenModelica is installed, the language basics are covered, and simple dynamic models (like [SimpleRamp](02_SimpleRamp/SimpleRamp.mo)) run and export data end to end. **Real chemical-process unit operations are not there yet.** Groundwork for stage 03 exists under [vendor/](vendor/) and [tools/](tools/), but it is unreviewed, undocumented, and **not ready to use** — please treat it as scratch work until its guide ships.

---

## 📘 Guide Series

Guides live in [docs/](docs/), each published in two formats: an editable source document and a distribution PDF.

| # | Guide | Level | Version | Status | Read |
| :---: | --- | --- | :---: | :---: | --- |
| **00** | Introduction to OpenModelica for Process Engineers | Beginner | `0.00` | ✅ Published | [📄 PDF](docs/01%20PDFs/00%20OpenModellica%20for%20Process%20Simulations.pdf) · [📝 DOCX](docs/00%20Docs/00%20OpenModellica%20for%20Process%20Simulations.docx) |
| **01** | Loading Libraries into OpenModelica | Intermediate | — | 🚧 In progress | — |
| **02** | Thermodynamic Packages for Process Engineers | Intermediate | — | 📋 Planned | — |
| **03** | Unit Operations I — Mixers, Splitters, Heaters, Valves | Intermediate | — | 📋 Planned | — |
| **04** | Unit Operations II — Flash, Columns, Reactors | Advanced | — | 📋 Planned | — |

### Inside Guide 00

<details>
<summary><b>Click to expand the table of contents</b></summary>

1. **What is OpenModelica?** — the short definition, why a process engineer should care, the ecosystem (OMEdit, OMShell, OMPython, OMNotebook), and the OMC compiler
2. **Installation** — Windows, Linux (Ubuntu/Debian), macOS, and verifying your install
3. **Navigating the OMEdit interface** — launching it, the main window layout, customising your workspace
4. **The building blocks** — Modelica core data types and the structure of a model
5. **Creating and writing a model file** — a simple time-based code block, packages and modules, running and visualising it
6. **Exporting simulation data** — a deep dive using `SimpleRamp`: where the output files live, graphical plot export, and CSV export
7. **References and source code**

</details>

### 🧩 Adding a new guide

The `docs/` layout is deliberately simple so it extends without reorganising anything:

```
docs/
├── 00 Docs/     # Editable sources (.docx) — the master copy you write in
└── 01 PDFs/     # Exported PDFs — what readers actually download
```

To publish the next one:

1. Write it as `docs/00 Docs/NN <Title>.docx`, keeping the two-digit `NN` prefix so guides sort in reading order.
2. Export to `docs/01 PDFs/NN <Title>.pdf` under the **same** base name — matching names is what keeps source and PDF paired.
3. Add a row to the [Guide Series](#-guide-series) table above, with its level, version and links.
4. Flip the matching stage in [Where This Project Is Right Now](#-where-this-project-is-right-now) to ✅, and bump the `guides` badge count at the top.
5. Add the companion model in a numbered folder (`03_My_Model/`) and link it from the guide.

> 💡 Every guide carries its own `Version` field on the title page. Bump that when you revise a published guide, and update its row in the table — readers can then tell a fresh revision from a stale download.

---

## ⚙️ Installation & Setup

> 📘 **Guide 00 covers this in full**, with screenshots and per-platform detail, including the Windows gotcha about non-English characters in your username. The summary below gets you running; [read the guide](docs/01%20PDFs/00%20OpenModellica%20for%20Process%20Simulations.pdf) for the reasoning behind each step.

### Prerequisites

| Requirement | Version | Notes |
| --- | --- | --- |
| [OpenModelica](https://openmodelica.org/download/) | **1.27.0** (64-bit) | The version everything here is verified against. |
| Modelica Standard Library | **3.2.3** | Ships with OpenModelica. Selectable under *Tools → Options → Libraries*. |
| [Python](https://www.python.org/downloads/) | **3.12+** | Optional — only for the tooling in [tools/](tools/). |

### 1. Install OpenModelica

**Windows** — download the `.exe` installer (~1.85 GB) from the [official download page](https://openmodelica.org/download/) and run it.

> [!WARNING]
> OpenModelica does not handle non-English (double-byte) characters well. Your **Windows username and install path must contain only plain English letters and numbers**, with no spaces or special characters. If your username has special characters, create a new account (e.g. `ProcessEng`) and install from there. This trips up more people than any other step.

**Linux (Ubuntu / Debian)**

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg lsb-release

curl -fsSL https://build.openmodelica.org/apt/openmodelica.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/openmodelica-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] https://build.openmodelica.org/apt $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/openmodelica.list

sudo apt-get update
sudo apt-get install openmodelica
```

**macOS** — see §2.3 of Guide 00.

### 2. Verify the install

```bash
omc --version
# OpenModelica v1.27.0 (64-bit)
```

Then launch **OMEdit** and confirm the welcome screen appears.

### 3. Clone this repository

```bash
git clone https://github.com/virajdesai0309/OpenModellica_Process_Models.git
cd OpenModellica_Process_Models
```

Open any `.mo` file through **File → Open Model/Library File** in OMEdit.

### 4. Optional — Python environment

Only needed for the scripts in [tools/](tools/). The project uses [uv](https://github.com/astral-sh/uv), but plain `venv` works too.

```bash
uv sync                          # or:
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\activate
```

> ℹ️ No third-party dependencies — the tooling drives `omc` through the Python standard library alone.

### 5. Loading external process libraries

> 🚧 **Coming in Guide 01.** Loading a chemical-process library into OpenModelica and getting it to compile against the right MSL version is fiddly enough to deserve its own walkthrough. It is being written and tested now. Until it ships, treat anything under [vendor/](vendor/) as unsupported scratch work.

---

## 🚀 Usage

### Your first model — `SimpleRamp`

The smallest useful Modelica model: an output that ramps linearly with simulation time. It exists to prove the whole chain works — write, check, simulate, plot, export.

```modelica
model SimpleRamp
  Real output_value;            // A variable to hold our result
  parameter Real slope = 2.0;   // A user-defined parameter
equation
  output_value = slope * time;  // 'time' is a built-in simulation variable
end SimpleRamp;
```

Three ideas carry most of the language:

| Concept | What it means |
| --- | --- |
| `parameter` | Fixed for the whole run — set it before simulating, like a design specification. |
| `Real output_value` | A variable the solver computes at every time step. |
| `equation` | A **relationship**, not an assignment. You state that it holds; the compiler decides how to solve for it. |

**Run it:**

1. Open [02_SimpleRamp/SimpleRamp.mo](02_SimpleRamp/SimpleRamp.mo) in OMEdit.
2. Press **Check Model** (✔) — confirms the equation count matches the variable count.
3. Press **Simulate** (▶).
4. Tick `output_value` in the Variables Browser to plot it.

You should see a straight line of slope 2 — [Ramp_Result.png](02_SimpleRamp/Ramp_Result.png).

**Export the results:** right-click the plot → *Export* for an image, or use the CSV export to get [exportedVariables.csv](02_SimpleRamp/exportedVariables.csv) for analysis in Excel, pandas, or anything else. Guide 00 §6 walks through both, and explains where OpenModelica puts its output files.

### From the command line

```bash
omc -s 02_SimpleRamp/SimpleRamp.mo
```

Or with an `omc` script:

```modelica
loadFile("02_SimpleRamp/SimpleRamp.mo");   getErrorString();
simulate(SimpleRamp, stopTime = 10, outputFormat = "csv");
```

### Next: the OMEdit workflow end to end

[00 Example_One/](00%20Example_One/) goes further — a custom icon drawn with graphical primitives, a first-order decay equation, and a full pass through check → translate → simulate → plot. Its 13 screenshots are narrated in [Modeling_Process.md](00%20Example_One/Modeling_Process.md).

---

## 📁 Project Structure

```
OpenModellica_Process_Models/
│
├── docs/                              # 📘 The guide series
│   ├── 00 Docs/                       #   Editable sources (.docx)
│   │   └── 00 OpenModellica for Process Simulations.docx
│   └── 01 PDFs/                       #   Exported PDFs for readers
│       └── 00 OpenModellica for Process Simulations.pdf
│
├── 00 Example_One/                    # 🧪 Companion model: the OMEdit workflow
│   ├── Example_One.mo                 #   Custom icon + first-order decay
│   ├── Modeling_Process.md            #   Narrated walkthrough
│   └── images/                        #   13 screenshots, one per step
│
├── 01_Material_Stream/                # 🚧 Companion model: first material stream
│   └── MyModels.mo                    #   WIP — depends on stage 03
│
├── 02_SimpleRamp/                     # 🧪 Companion model: first dynamic model
│   ├── SimpleRamp.mo                  #   output_value = slope * time
│   ├── exportedVariables.csv          #   CSV export from Guide 00 §6
│   └── Ramp_Result.png                #   Result plot
│
├── tools/                             # 🚧 Automation (internal, undocumented)
│   └── run_regression.py              #   Batch compile/simulate harness
│
├── vendor/                            # 🚧 Third-party libraries — WIP, see stage 03
│   └── OMChemSim-v1.0/                #   OMChemSim (FOSSEE, IIT Bombay) — BSD-3
│
├── MODELLING_GUIDE.md                 # 🚧 Working notes for stage 03+ (unpolished)
├── pyproject.toml                     # Python project metadata (3.12+)
├── main.py                            # Python entry point stub
├── LICENSE                            # BSD 3-Clause + third-party notices
└── README.md                          # You are here
```

### Root directory guide

| Directory | Purpose |
| --- | --- |
| **[docs/](docs/)** | The written guide series — the main deliverable. `00 Docs/` holds editable sources, `01 PDFs/` holds the exported PDFs readers download. Extends by dropping in the next numbered pair. |
| **[00 Example_One/](00%20Example_One/)** | Onboarding example. Deliberately non-physical: it exists to exercise the full OMEdit workflow — custom icon, check, translate, simulate, plot — with a screenshot at every step. |
| **[02_SimpleRamp/](02_SimpleRamp/)** | The minimal dynamic model from Guide 00, kept alongside its CSV export and result plot so the data-export chapter can be followed with real files. |
| **[01_Material_Stream/](01_Material_Stream/)** | 🚧 First attempt at a real process stream. Depends on the external library work in stage 03 and **will not compile on its own yet**. |
| **[tools/](tools/)** | 🚧 Internal automation used while testing models in bulk. Undocumented; expect it to change. |
| **[vendor/](vendor/)** | 🚧 Third-party libraries kept separate from original work. Groundwork for stage 03 — unreviewed and not ready for use. Its licence and attribution are preserved in place. |

> 📐 **Convention:** each companion model gets its own `NN_Name/` folder, numbered in the order it appears in the guides, holding the `.mo` file plus any results or notes that belong with it.

---

## 🗺️ Roadmap

**Near term — finishing what is started**

- [ ] **Guide 01: Loading libraries** — get an external process library compiling reliably, then write it up
- [ ] Write up stage 02 (custom icons and the full OMEdit workflow) around `Example_One`
- [ ] Make [01_Material_Stream/](01_Material_Stream/) reproducible once the library guide lands

**Medium term — process engineering proper**

- [ ] **Guide 02: Thermodynamic packages** — which property method to use, and what breaks when you choose wrong
- [ ] **Guide 03: Unit operations I** — mixers, splitters, heaters, coolers, valves, pumps, tested one at a time
- [ ] **Guide 04: Unit operations II** — flash drums, distillation and absorption columns, reactors
- [ ] Flowsheeting: connecting unit operations, recycle loops, and getting them to converge

**Longer term**

- [ ] OMPython — driving simulations from Python for parametric studies
- [ ] Steady-state → dynamic modelling of the same process
- [ ] Digital-twin and real-time-optimisation examples
- [ ] CI that compiles every published model on each push

---

## 🤝 Contributing

This is a learning journey published in the open, and feedback is genuinely welcome — especially from engineers who have hit the same walls.

**Particularly useful:**

- 🐛 **Corrections** — if something in a guide is wrong or unclear, open an issue. Being corrected early is the whole point of learning in public.
- 💡 **Suggestions** — a topic that deserves a guide, or an ordering that would teach better
- 🧪 **Models** — worked examples that illustrate a concept cleanly

**To contribute a model:**

1. Fork and branch: `git checkout -b feature/my-model`
2. Add it in a numbered folder following the existing convention (e.g. `03_My_Model/`)
3. Include a short note on the physics it represents and how to run it
4. Confirm it checks and simulates on OpenModelica 1.27.0
5. Open a pull request

> ℹ️ Please don't build on anything under [vendor/](vendor/) or [tools/](tools/) yet — both are unstable until stage 03 ships.

---

## 📖 References

### Core software

1. **OpenModelica** — Open Source Modelica Consortium (OSMC), operated as a project of RISE SICS East AB in collaboration with Linköping University.
   <https://openmodelica.org/>
2. **Modelica Language Specification** — Modelica Association.
   <https://specification.modelica.org/>
3. **Modelica Standard Library (MSL)** — Modelica Association.
   <https://github.com/modelica/ModelicaStandardLibrary>
4. **OMChemSim** — FOSSEE, IIT Bombay. Open-source chemical process simulator written in Modelica.
   <https://github.com/FOSSEE/OMChemSim>
5. **ChemSep** — component property database.
   <https://www.chemsep.org/>

### Suggested reading

6. Fritzson, P. — *Principles of Object-Oriented Modeling and Simulation with Modelica 3.3: A Cyber-Physical Approach*, Wiley-IEEE Press, 2014.
7. Poling, B. E., Prausnitz, J. M., O'Connell, J. P. — *The Properties of Gases and Liquids*, 5th ed., McGraw-Hill, 2001.
8. Smith, J. M., Van Ness, H. C., Abbott, M. M. — *Introduction to Chemical Engineering Thermodynamics*, 8th ed., McGraw-Hill, 2018.

### Documentation in this repository

9. **Guide 00 — Introduction to OpenModelica for Process Engineers** — [PDF](docs/01%20PDFs/00%20OpenModellica%20for%20Process%20Simulations.pdf)
10. **Example One — Modelling Process walkthrough** — [Modeling_Process.md](00%20Example_One/Modeling_Process.md)

---

## 📄 License

Released under the **BSD 3-Clause License** — see [LICENSE](LICENSE) for the full text.

You are free to use, modify and redistribute this work, including commercially, provided the copyright notice and disclaimer are retained.

**Third-party components.** [vendor/](vendor/) contains a modified copy of **OMChemSim v1.0**, originally developed by **FOSSEE, IIT Bombay**, distributed under its own [BSD 3-Clause License](vendor/OMChemSim-v1.0/LICENSE) (`Copyright (c) 2020, FOSSEE`). Modifications are recorded in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md). Full third-party notices are in [LICENSE](LICENSE).

> [!CAUTION]
> **Educational use only.** Everything here is published for learning. The models are simplified representations of complex physical phenomena and are **not validated for industrial use**. For design, operational decisions and safety-critical applications, consult qualified professional engineers and use validated, commercially supported software.

---

## 👤 Author

**Viraj Desai**

Process engineer, process modelling engineer and simulation engineer with around 6 years of experience in **real-time optimisation**, **digital twins**, and **process modelling** — currently exploring what open-source tooling can do for the discipline, and writing down everything learned along the way.

[![GitHub](https://img.shields.io/badge/GitHub-virajdesai0309-181717?logo=github&logoColor=white)](https://github.com/virajdesai0309)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-viraj--desai--03sept-0A66C2?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/viraj-desai-03sept)
[![Email](https://img.shields.io/badge/Email-virajdesai0309@gmail.com-EA4335?logo=gmail&logoColor=white)](mailto:virajdesai0309@gmail.com)

---

## 🙏 Acknowledgements

- **The OpenModelica community and the Open Source Modelica Consortium** — for building and maintaining a transparent, high-quality simulation environment that anyone can use, and for democratising engineering software.
- **Modelica Association** — for the language and the standard library.
- **FOSSEE, IIT Bombay** — for developing and open-sourcing OMChemSim.
- **The wider open-source ecosystem** — whose maintainers make projects like this possible.

---

<div align="center">

⭐ If this helps your process modelling journey, consider starring the repository.

**More guides are on the way** — [see what's next](#️-roadmap)

</div>
