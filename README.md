<div align="center">

# OpenModelica for Process Engineers

**A learn-in-public guide series on open-source process simulation — with every model I build along the way.**

[![Guides](https://img.shields.io/badge/guides-2%20published-blue.svg)](#-guide-series)
[![Stage](https://img.shields.io/badge/stage-02%20Material%20Stream%20Modelling-informational.svg)](#-where-this-project-is-right-now)
[![Modelica](https://img.shields.io/badge/Modelica-4.1.0-9cf.svg)](https://modelica.org/)
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
> **This is an active learning journey, not a finished product.** Guide 00 is published; Guide 01's models all run and the write-up is in progress. See [Where This Project Is Right Now](#-where-this-project-is-right-now) for an honest status of every stage. Everything here is for **educational use** — these are teaching models, not validated industrial ones.

### ✨ What you get today

- **A complete beginner's guide** covering what OpenModelica is, installing it on Windows/Linux/macOS, navigating OMEdit, Modelica language basics, and exporting simulation data — [available as a PDF](docs/01%20PDFs/).
- **Runnable companion models** for every worked example in that guide.
- **A screenshot-by-screenshot OMEdit walkthrough** of a first model, from blank canvas to plotted result.
- **Material streams that actually solve** — a hydrocarbon flash on Peng-Robinson and a water stream on the IAPWS-IF97 steam tables, in the same model, with a patched process library behind them and notes on every patch.
- **A parametric-study harness** that compiles once and sweeps a grid of operating points, so a design of experiments over a stream costs seconds rather than an afternoon.
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
| **02** | **Material stream modelling** — three things that only make sense together: drawing a **custom icon** and taking a model through the full OMEdit workflow, **loading an external process library** and getting it to compile, and then building an actual **material stream** on top of it — one stream, several streams in one model, two property methods side by side, and a parametric study over the lot | ✅ **Published** |
| **03** | **Thermodynamic packages** — property methods, when each one applies, and what happens when you pick the wrong one | 📋 **Planned** |
| **04** | **Unit operations** — mixers, splitters, heaters, coolers, valves, pumps | 📋 **Planned** |
| **05** | **Separation** — flash drums, distillation and absorption columns | 📋 **Planned** |
| **06** | **Reactors** — conversion, equilibrium, CSTR, PFR | 📋 **Planned** |
| **07** | **Flowsheeting** — connecting unit operations into a full process, recycle loops, convergence | 📋 **Planned** |
| **08** | **OMPython & automation** — driving simulations from Python, toward digital twins and real-time optimisation | 💡 **Idea** |

**Legend** — ✅ Published · 🟢 Built, being written up · 🚧 In progress · 📋 Planned · 💡 Idea

> [!IMPORTANT]
> **In practical terms:** stages 00 and 01 are published and stage 02 now *runs* — [03_Multi_Stream/](03_Multi_Stream/) holds a model with a Peng-Robinson hydrocarbon stream and a steam-table water stream in it, and [tools/run_doe.py](tools/run_doe.py) sweeps a grid of operating points over them. What is missing is the **write-up**, not the code. Everything from stage 03 on — real unit operations, columns, reactors — is still ahead.
>
> Stage 02 required patching the vendored library in [vendor/](vendor/); those changes are recorded in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md) and checked by [tools/run_regression.py](tools/run_regression.py). Read [MODELLING_GUIDE.md](MODELLING_GUIDE.md) before building on it — the library has sharp edges, and that file is where they are written down.

---

## 📘 Guide Series

Guides live in [docs/](docs/), each published in two formats: an editable source document and a distribution PDF.

| # | Guide | Level | Version | Status | Read |
| :---: | --- | --- | :---: | :---: | --- |
| **00** | Introduction to OpenModelica for Process Engineers | Beginner | `0.00` | ✅ Published | [📄 PDF](docs/01%20PDFs/00%20OpenModellica%20for%20Process%20Simulations.pdf) · [📝 DOCX](docs/00%20Docs/00%20OpenModellica%20for%20Process%20Simulations.docx) |
| **01** | Material Stream Modelling in OpenModelica | Intermediate | — | 🚧 Being written | [📝 DOCX](docs/00%20Docs/01%20Material%20Stream%20Modelling%20in%20OpenModellica.docx) |
| **02** | Thermodynamic Packages for Process Engineers | Intermediate | — | 📋 Planned | — |
| **03** | Unit Operations I — Mixers, Splitters, Heaters, Valves | Intermediate | — | 📋 Planned | — |
| **04** | Unit Operations II — Flash, Columns, Reactors | Advanced | — | 📋 Planned | — |

> 📌 **Guide 01 absorbed what used to be planned as two separate guides.** Custom icons and library loading were each going to get their own instalment, but neither stands on its own: you draw an icon so a stream has something to look like on the canvas, and you load a library so the stream has thermodynamics behind it. Both only pay off at the moment a material stream actually solves, so all three now ship together.

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
| Modelica Standard Library | **4.1.0** | Ships with OpenModelica and is the default. Selectable under *Tools → Options → Libraries*. |
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

A copy of **OMChemSim**, patched to compile on OpenModelica 1.27.0, ships in [vendor/](vendor/). Load it in this order — getting it wrong produces errors that look like language problems rather than loading problems:

1. **Tools → Options → Libraries** → confirm the Modelica system library is **4.x**. 4.1.0 is the default, so usually there is nothing to change — but it must be resolved *before* anything else loads.
2. **File → Open Model/Library File** → `vendor/OMChemSim-v1.0/Simulator/package.mo`
3. Open the model you want on top of it, e.g. `03_Multi_Stream/MultiStream.mo`.

Or from a script:

```modelica
loadModel(Modelica, {"4.1.0"});
loadFile("vendor/OMChemSim-v1.0/Simulator/package.mo");
```

> [!NOTE]
> The vendored copy is **modified**. Every change is recorded in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md) with the error it fixes, and [tools/run_regression.py](tools/run_regression.py) recompiles every example in it so an OpenModelica upgrade cannot break it quietly. Read [MODELLING_GUIDE.md](MODELLING_GUIDE.md) before writing your own models against it — that is where the sharp edges are written down. The narrated walkthrough is coming in Guide 01.

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

### Material streams — two property methods in one model

Once an external process library is loaded, a stream stops being a variable with a number in it and becomes a flash calculation. [03_Multi_Stream/MultiStream.mo](03_Multi_Stream/MultiStream.mo) puts two very different ones in the same model:

| Stream | Components | Property method | Comes from |
| --- | --- | --- | --- |
| `HC` | propane / n-butane / n-pentane | **Peng-Robinson** — cubic equation of state, both phases | OMChemSim |
| `W` | pure water | **IAPWS-IF97 steam tables** | `Modelica.Media.Water.StandardWater` (MSL) |

They are not interchangeable, and that is the lesson. OMChemSim knows about *composition* — K-values, bubble and dew pressure, a vapour fraction. `Modelica.Media` knows about *one substance, very accurately* — it will give you the enthalpy of superheated steam to reference quality and cannot flash a mixture at all. Real flowsheets have both.

```bash
omc 03_Multi_Stream/run.mos      # loads both libraries, simulates, writes CSV
```

At 5 bar / 320 K the hydrocarbon stream comes back 92.4 % vapour between a bubble pressure of 9.70 bar and a dew pressure of 4.26 bar; at 10 bar / 500 K the water stream comes back as steam 47 K superheated at 2891 kJ/kg. See [03_Multi_Stream/README.md](03_Multi_Stream/README.md) for the full walkthrough, including the load order that OMEdit needs.

### Design of experiments — sweeping the operating point

Two ways to move an operating point around, and they are good at different things.

**In the model, over simulation time.** Neither stream has a derivative in it, so `MultiStream.StreamSweep` is not a dynamic model — it is a sequence of steady-state solves with the specification walked a little between each. Set the `_start`/`_end` pair of one factor, leave the others equal, and the result file is that factor's response curve. Each step starts from the previous answer, which is what carries a Peng-Robinson flash smoothly across the two-phase region.

**Outside the model, over a grid.** For a real factorial design, [tools/run_doe.py](tools/run_doe.py) compiles the model **once** and then re-runs the executable per point with `-override`, so a 100-point study costs one compile rather than a hundred:

```bash
python tools/run_doe.py                                     # the built-in grid
python tools/run_doe.py --factor T_hc=300,310,320 \
                        --factor P_hc=3e5,5e5,8e5 \
                        --factor z_c3=0.3,0.5,0.7           # your own
```

It drops composition combinations whose balance would be negative, retries a point that will not converge with a different vapour-fraction start value, and writes one row per solved point to `03_Multi_Stream/doe_results.csv`. Points that never converge are listed rather than hidden — finding the edge of the envelope is half the reason to run the grid.

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
├── 01_Material_Stream/                # 🧪 Companion model: a single material stream
│   └── MyModels.mo                    #   Ethanol/water, Raoult, TP flash
│
├── 02_SimpleRamp/                     # 🧪 Companion model: first dynamic model
│   ├── SimpleRamp.mo                  #   output_value = slope * time
│   ├── exportedVariables.csv          #   CSV export from Guide 00 §6
│   └── Ramp_Result.png                #   Result plot
│
├── 03_Multi_Stream/                   # 🧪 Companion model: two property methods at once
│   ├── MultiStream.mo                 #   PR hydrocarbon + IF97 steam, and a sweep
│   ├── run.mos                        #   Load both libraries and simulate
│   ├── README.md                      #   Walkthrough, load order, DoE notes
│   └── doe_results.csv                #   Written by tools/run_doe.py
│
├── tools/                             # 🔧 Automation
│   ├── run_regression.py              #   Batch compile/simulate harness
│   └── run_doe.py                     #   Factorial parameter study, one compile
│
├── vendor/                            # 📦 Third-party libraries, patched
│   └── OMChemSim-v1.0/                #   OMChemSim (FOSSEE, IIT Bombay) — BSD-3
│
├── MODELLING_GUIDE.md                 # 📐 How to build models against the patched library
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
| **[01_Material_Stream/](01_Material_Stream/)** | The smallest real process stream: ethanol/water, Raoult's law, TP flash. Needs OMChemSim loaded first — see [MODELLING_GUIDE.md](MODELLING_GUIDE.md). |
| **[03_Multi_Stream/](03_Multi_Stream/)** | Two streams in one model on two different property methods, plus the sweep and grid studies over them. Has its own [README](03_Multi_Stream/README.md). |
| **[tools/](tools/)** | `run_regression.py` recompiles every model in the vendored library so an OpenModelica upgrade cannot break it quietly; `run_doe.py` runs a factorial parameter study off a single compile. |
| **[vendor/](vendor/)** | Third-party libraries kept separate from original work. A **modified** OMChemSim — every patch and the error it fixes is recorded in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md), and its licence and attribution are preserved in place. |

> 📐 **Convention:** each companion model gets its own `NN_Name/` folder, numbered in the order it appears in the guides, holding the `.mo` file plus any results or notes that belong with it.

---

## 🗺️ Roadmap

**Near term — finishing what is started**

- [x] Get an external process library compiling reliably against OpenModelica 1.27.0
- [x] A material stream that solves — one stream, then several in one model, on two different property methods
- [x] A parametric study over those streams that does not recompile per point
- [ ] **Guide 01: Material stream modelling** — write up custom icons, library loading and the streams above, with screenshots
- [ ] Widen the operating envelope: the Peng-Robinson flash is solid inside the two-phase region and above it, and does not converge below the bubble point — see [03_Multi_Stream/README.md](03_Multi_Stream/README.md)

**Medium term — process engineering proper**

- [ ] **Guide 02: Thermodynamic packages** — which property method to use, and what breaks when you choose wrong; the Peng-Robinson vs Raoult vs steam-table comparison in `03_Multi_Stream` is the seed of it
- [ ] **Guide 03: Unit operations I** — mixers, splitters, heaters, coolers, valves, pumps, tested one at a time
- [ ] **Guide 04: Unit operations II** — flash drums, distillation and absorption columns, reactors
- [ ] Flowsheeting: connecting unit operations, recycle loops, and getting them to converge

**Longer term**

- [ ] OMPython — driving simulations from Python, building on [tools/run_doe.py](tools/run_doe.py)
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

> ℹ️ If your model touches [vendor/](vendor/), read [MODELLING_GUIDE.md](MODELLING_GUIDE.md) first and run `python tools/run_regression.py` before and after. Patches to the vendored library are welcome, but each one needs a line in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md) saying what error it fixes, and the regression suite must still pass.

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
6. **IAPWS-IF97** — International Association for the Properties of Water and Steam, *Revised Release on the IAPWS Industrial Formulation 1997 for the Thermodynamic Properties of Water and Steam*. The steam tables behind `Modelica.Media.Water.StandardWater`.
   <https://www.iapws.org/relguide/IF97-Rev.html>
7. **Modelica.Media** — Elmqvist, H., Tummescheit, H., Otter, M., *Object-Oriented Modeling of Thermo-Fluid Systems*, Modelica Conference 2003. The design behind the MSL media library.

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
