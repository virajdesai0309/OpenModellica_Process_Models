<div align="center">

# OpenModelica for Process Engineers

**A learn-in-public guide series on open-source process simulation — with every model I build along the way.**

[![Guides](https://img.shields.io/badge/guides-2%20published-blue.svg)](#-guide-series)
[![Models](https://img.shields.io/badge/models-4%20companion-blueviolet.svg)](#-project-structure)
[![Next](https://img.shields.io/badge/next-04%20Pumps%2C%20Heaters%20%26%20Compressors-informational.svg)](#next-up--unit-operations)
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
> **This is an active learning journey, not a finished product.** Guides 00 and 01 are published, and the models behind them run. What comes next is unit operations — a pump system, heaters and coolers, compressors and expanders — bolted onto the streams that now solve. See [Where This Project Is Right Now](#-where-this-project-is-right-now) for an honest status of every stage. Everything here is for **educational use** — these are teaching models, not validated industrial ones.

### ✨ What you get today

- **A complete beginner's guide** covering what OpenModelica is, installing it on Windows/Linux/macOS, navigating OMEdit, Modelica language basics, and exporting simulation data — [available as a PDF](docs/01%20PDFs/).
- **Runnable companion models** for every worked example in that guide.
- **A screenshot-by-screenshot OMEdit walkthrough** of a first model, from blank canvas to plotted result.
- **Material streams that actually solve** — a hydrocarbon flash on Peng-Robinson and a water stream on the IAPWS-IF97 steam tables, in the same model, with a patched process library behind them and notes on every patch.
- **A parametric-study harness** that compiles once and sweeps a grid of operating points, so a design of experiments over a stream costs seconds rather than an afternoon.
- **Written-down sharp edges** — [MODELLING_GUIDE.md](MODELLING_GUIDE.md) for building your own models on the patched library, and [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md) for every patch and the exact error it fixes. Both are listed in the [Documentation Map](#-documentation-map).
- **A commitment to keep going** — the roadmap below is what is actually being worked on next, not a wish list.

---

## 📑 Table of Contents

- [Description](#-description)
- [Where This Project Is Right Now](#-where-this-project-is-right-now)
- [Guide Series](#-guide-series)
- [Documentation Map](#-documentation-map)
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
| **03** | **Thermodynamic packages** — Raoult, Peng-Robinson, Grayson-Streed, NRTL, UNIQUAC, UNIFAC: when each one applies, and what happens when you pick the wrong one | 📋 **Planned** |
| **04** | **Unit operations I — pressure changers** — a **pump system** first: head, efficiency, power draw and a pump curve swept over flow; then **valves** and the isenthalpic pressure drop across them | 📌 **Next up** |
| **05** | **Unit operations II — heat transfer** — **heater and cooler models** on a duty specification and on an outlet-temperature specification, then a two-sided **heat exchanger** coupled through an energy stream | 📋 **Planned** |
| **06** | **Unit operations III — compression & expansion** — **adiabatic compressors** and expanders, isentropic efficiency, discharge temperature, and why the property package matters more here than anywhere else | 📋 **Planned** |
| **07** | **Mixing & splitting** — mixers and splitters, and the first models where two streams have to agree on a composition | 📋 **Planned** |
| **08** | **Separation** — flash drums, distillation and absorption columns | 📋 **Planned** |
| **09** | **Reactors** — conversion, equilibrium, CSTR, PFR | 📋 **Planned** |
| **10** | **Flowsheeting** — connecting unit operations into a full process, recycle loops, convergence | 📋 **Planned** |
| **11** | **OMPython & automation** — driving simulations from Python, toward digital twins and real-time optimisation | 💡 **Idea** |

**Legend** — ✅ Published · 📌 Next up · 🟢 Built, being written up · 🚧 In progress · 📋 Planned · 💡 Idea

> 📌 **Why stage 04 and not stage 03?** Stage 03 is a *write-up* — the property-method comparison it needs already exists in [03_Multi_Stream/](03_Multi_Stream/). Stage 04 is new *modelling*, and modelling is the slower half, so it starts now and the thermodynamics guide is written alongside it.

> [!IMPORTANT]
> **In practical terms:** stages 00, 01 and 02 are done — published as PDFs, with models that run. [03_Multi_Stream/](03_Multi_Stream/) holds a Peng-Robinson hydrocarbon stream and a steam-table water stream in one model, and [tools/run_doe.py](tools/run_doe.py) sweeps a grid of operating points over them.
>
> **The line is drawn after streams.** Everything from stage 04 on — pumps, heaters and coolers, compressors, columns, reactors — is still ahead. The blocks for them already sit in the vendored library ([`Simulator.UnitOperations`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/)); what has not been done is connecting them to streams that solve, checking the numbers, and writing it up. That work is next — see [Next up — unit operations](#next-up--unit-operations).
>
> Getting this far required patching the vendored library in [vendor/](vendor/); those changes are recorded in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md) and checked by [tools/run_regression.py](tools/run_regression.py). Read [MODELLING_GUIDE.md](MODELLING_GUIDE.md) before building on it — the library has sharp edges, and that file is where they are written down.

---

## 📘 Guide Series

Guides live in [docs/](docs/), each published in two formats: an editable source document and a distribution PDF.

| # | Guide | Level | Version | Status | Read |
| :---: | --- | --- | :---: | :---: | --- |
| **00** | Introduction to OpenModelica for Process Engineers | Beginner | `0.00` | ✅ Published | [📄 PDF](docs/01%20PDFs/00%20OpenModellica%20for%20Process%20Simulations.pdf) · [📝 DOCX](docs/00%20Docs/00%20OpenModellica%20for%20Process%20Simulations.docx) |
| **01** | Material Stream Modelling in OpenModelica | Intermediate | `0.00` | ✅ Published | [📄 PDF](docs/01%20PDFs/01%20Material%20Stream%20Modelling%20in%20OpenModellica.pdf) · [📝 DOCX](docs/00%20Docs/01%20Material%20Stream%20Modelling%20in%20OpenModellica.docx) |
| **02** | Thermodynamic Packages for Process Engineers | Intermediate | — | 📋 Planned | — |
| **03** | Unit Operations I — Pumps, Pump Curves and Valves | Intermediate | — | 📌 Next up | — |
| **04** | Unit Operations II — Heaters, Coolers and Heat Exchangers | Intermediate | — | 📋 Planned | — |
| **05** | Unit Operations III — Compressors and Expanders | Intermediate | — | 📋 Planned | — |
| **06** | Unit Operations IV — Mixers, Splitters, Flash, Columns, Reactors | Advanced | — | 📋 Planned | — |

> 📌 **Guide 01 absorbed what used to be planned as two separate guides.** Loading an external process library and building a material stream were each going to get their own instalment, but neither stands on its own: you load a library so the stream has thermodynamics behind it, and the loading only pays off at the moment a stream actually solves. They ship together, with a troubleshooting chapter between them, because that is the order you hit them in. The custom-icon side of the OMEdit workflow is covered separately in [00 Example_One/Modeling_Process.md](00%20Example_One/Modeling_Process.md).

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

### Inside Guide 01

<details>
<summary><b>Click to expand the table of contents</b></summary>

1. **What is OMChemSim?** — what it is, what it can model, its licence and attribution, and why this guide uses a patched copy
2. **Importing the Simulator package** — locating it, loading it in OMEdit, setting up your own workspace model, verifying the import
3. **The key building blocks** — `Streams.MaterialStream`, `Files.ChemsepDatabase`, `Files.ThermodynamicPackages`, `Files.Interfaces.matConn`, `GuessModels`, `UnitOperations`
4. **Building a process model from scratch** — choosing a system, writing `MyFirstStream.mo`, a line-by-line explanation, and Check Model
5. **Troubleshooting: reading OpenModelica errors** — why errors are normal here, how to read a translation error, the six you will actually hit (broken imports, `model` vs `record` mismatch, missing `partial`, cross-class scoping, missing `each`, nonlinear initialisation), and how to tell a library fault from your own
6. **Declaring other streams in the same model** — composites that join a stream to a property package, a Peng-Robinson hydrocarbon stream, an IAPWS-IF97 water stream, unit mismatches between libraries, reference-state cautions, running both side by side, and walking the operating point over simulated time
7. **Results generation and exporting plots** — output files, graphical export, CSV export, and what is actually worth looking at for a material stream
8. **References and source code**

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

## 📚 Documentation Map

Not everything worth reading is a guide. This is every document in the repository, and when to open it.

| Document | What it is | When you need it |
| --- | --- | --- |
| [Guide 00 — Introduction to OpenModelica](docs/01%20PDFs/00%20OpenModellica%20for%20Process%20Simulations.pdf) | Install, OMEdit tour, language basics, first model, CSV export | Starting from zero |
| [Guide 01 — Material Stream Modelling](docs/01%20PDFs/01%20Material%20Stream%20Modelling%20in%20OpenModellica.pdf) | Loading OMChemSim, the building blocks, a stream from scratch, troubleshooting, two property methods in one model | Your first model with real thermodynamics in it |
| [MODELLING_GUIDE.md](MODELLING_GUIDE.md) | Working notes for building on the patched library: load order, composites, specifying a stream, the property packages, convergence, parametric studies, surviving an OpenModelica upgrade, reading its errors | Writing your own `.mo` against `vendor/` |
| [vendor/…/ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md) | Every patch applied to OMChemSim and the exact error it fixes — name resolution, rewritten initial guesses, strict-Modelica fixes, upstream bugs, Rachford-Rice flash closure, the MSL 3.2.3 → 4.x port | Something in the library behaves differently from upstream |
| [03_Multi_Stream/README.md](03_Multi_Stream/README.md) | Walkthrough of the two-property-method model: why two libraries at once, how to run it, what comes out, and how to sweep it | Running or extending the multi-stream model |
| [00 Example_One/Modeling_Process.md](00%20Example_One/Modeling_Process.md) | The OMEdit workflow narrated over 13 screenshots — custom icon, check, translate, simulate, plot | Learning the tool's UI rather than the physics |
| [structure.txt](structure.txt) | A flat listing of the vendored library's contents | Hunting for a class name inside OMChemSim |
| [LICENSE](LICENSE) | BSD 3-Clause plus third-party notices | Reusing any of this |

> 📘 **Guides are the narrative; `MODELLING_GUIDE.md` is the reference.** A guide teaches one topic in order, once. The modelling guide is the file to keep open while you work — it is updated whenever something new turns out to bite.

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
│   │   ├── 00 OpenModellica for Process Simulations.docx
│   │   └── 01 Material Stream Modelling in OpenModellica.docx
│   └── 01 PDFs/                       #   Exported PDFs for readers
│       ├── 00 OpenModellica for Process Simulations.pdf
│       └── 01 Material Stream Modelling in OpenModellica.pdf
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
│       ├── ATTRIBUTION.md             #   Every patch, and the error it fixes
│       ├── Fixes/                     #   Scripts used to apply the bulk patches
│       └── Simulator/                 #   Streams, UnitOperations, ThermodynamicPackages,
│                                      #   ChemsepDatabase, GuessModels, Examples
│
├── MODELLING_GUIDE.md                 # 📐 How to build models against the patched library
├── structure.txt                      # Flat listing of the vendored library
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
| **[vendor/](vendor/)** | Third-party libraries kept separate from original work. A **modified** OMChemSim — every patch and the error it fixes is recorded in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md), and its licence and attribution are preserved in place. Its `Simulator/UnitOperations/` is where the pump, heater, cooler, compressor and expander blocks live, waiting to be wired up. |
| **[MODELLING_GUIDE.md](MODELLING_GUIDE.md)** | The reference to keep open while modelling: load order, composites, convergence, parametric studies, upgrade checks, and how to read the library's errors. Listed with everything else in the [Documentation Map](#-documentation-map). |

> 📐 **Convention:** each companion model gets its own `NN_Name/` folder, numbered in the order it appears in the guides, holding the `.mo` file plus any results or notes that belong with it.

---

## 🗺️ Roadmap

**Done**

- [x] Get an external process library compiling reliably against OpenModelica 1.27.0
- [x] A material stream that solves — one stream, then several in one model, on two different property methods
- [x] A parametric study over those streams that does not recompile per point
- [x] **Guide 00: Introduction to OpenModelica** — published as a PDF
- [x] **Guide 01: Material stream modelling** — published as a PDF, including the troubleshooting chapter
- [x] Write down the library's sharp edges in [MODELLING_GUIDE.md](MODELLING_GUIDE.md) and every patch in [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md)

### Next up — unit operations

A stream that solves is only interesting once something happens to it. The blocks below already exist in the vendored library; what is missing is a worked model for each one, sitting on streams that converge, with the numbers checked and a sweep over the interesting parameter. **That is the next block of work, in this order.**

| # | Model | Built on | What it will show |
| :---: | --- | --- | --- |
| **1** | **Pump system** | [`CentrifugalPump`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/CentrifugalPump.mo) | Pressure rise across a pump, efficiency and shaft power, and a **pump curve** generated by sweeping flow with [tools/run_doe.py](tools/run_doe.py) rather than by hand |
| **2** | **Heater and cooler** | [`Heater`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/Heater.mo) · [`Cooler`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/Cooler.mo) | The same block specified two ways — fix the duty and let the outlet temperature fall out, or fix the outlet temperature and solve for duty — plus what happens when heating walks a stream across its bubble point |
| **3** | **Compressor and expander** | [`AdiabaticCompressor`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/AdiabaticCompressor.mo) · [`AdiabaticExpander`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/AdiabaticExpander.mo) | Isentropic efficiency, discharge temperature, power — and why the choice of property package shows up harder here than anywhere upstream of it |
| **4** | **Valve** | [`Valve`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/Valve.mo) | Isenthalpic pressure drop and the Joule-Thomson temperature change across it — the cheapest unit operation to model and the easiest to get wrong |
| **5** | **Heat exchanger** | [`HeatExchanger`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/HeatExchanger.mo) | Two streams coupled through an [`EnergyStream`](vendor/OMChemSim-v1.0/Simulator/Streams/EnergyStream.mo) — the first model where one stream's solution depends on another's |
| **6** | **Mixer and splitter** | [`Mixer`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/Mixer.mo) · [`Splitter`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/Splitter.mo) | Combining and dividing streams, and the first place two streams must agree on a composition |

Each gets its own numbered folder, a `run.mos` that loads and simulates it from the command line, and a row in the regression suite.

**Medium term — process engineering proper**

- [ ] **Guide 02: Thermodynamic packages** — which property method to use, and what breaks when you choose wrong; the Peng-Robinson vs Raoult vs steam-table comparison in `03_Multi_Stream` is the seed of it
- [ ] **Guide 03: Unit operations I** — the pump system and valves, written up with screenshots
- [ ] **Guide 04: Unit operations II** — heaters, coolers and heat exchangers
- [ ] **Guide 05: Unit operations III** — compressors and expanders
- [ ] **Guide 06: Unit operations IV** — mixers, splitters, flash drums, distillation and absorption columns, reactors
- [ ] Flowsheeting: connecting unit operations, recycle loops (the library ships a [`RecycleBlock`](vendor/OMChemSim-v1.0/Simulator/UnitOperations/RecycleBlock.mo)), and getting them to converge
- [ ] Widen the operating envelope: the Peng-Robinson flash is solid inside the two-phase region and above it, and does not converge below the bubble point — see [03_Multi_Stream/README.md](03_Multi_Stream/README.md)

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

8. Fritzson, P. — *Principles of Object-Oriented Modeling and Simulation with Modelica 3.3: A Cyber-Physical Approach*, Wiley-IEEE Press, 2014.
9. Poling, B. E., Prausnitz, J. M., O'Connell, J. P. — *The Properties of Gases and Liquids*, 5th ed., McGraw-Hill, 2001.
10. Smith, J. M., Van Ness, H. C., Abbott, M. M. — *Introduction to Chemical Engineering Thermodynamics*, 8th ed., McGraw-Hill, 2018.
11. Green, D. W., Southard, M. Z. — *Perry's Chemical Engineers' Handbook*, 9th ed., McGraw-Hill, 2018. The reference behind the pump, compressor and heat-exchanger models coming next.

### Documentation in this repository

See the [Documentation Map](#-documentation-map) for what each one is for.

12. **Guide 00 — Introduction to OpenModelica for Process Engineers** — [PDF](docs/01%20PDFs/00%20OpenModellica%20for%20Process%20Simulations.pdf) · [DOCX](docs/00%20Docs/00%20OpenModellica%20for%20Process%20Simulations.docx)
13. **Guide 01 — Material Stream Modelling in OpenModelica** — [PDF](docs/01%20PDFs/01%20Material%20Stream%20Modelling%20in%20OpenModellica.pdf) · [DOCX](docs/00%20Docs/01%20Material%20Stream%20Modelling%20in%20OpenModellica.docx)
14. **Building models against the patched OMChemSim** — [MODELLING_GUIDE.md](MODELLING_GUIDE.md)
15. **OMChemSim patch record** — [ATTRIBUTION.md](vendor/OMChemSim-v1.0/ATTRIBUTION.md)
16. **Material streams: two property methods in one model** — [03_Multi_Stream/README.md](03_Multi_Stream/README.md)
17. **Example One — Modelling Process walkthrough** — [Modeling_Process.md](00%20Example_One/Modeling_Process.md)

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

**Unit operations are next** — pumps, heaters and coolers, compressors — [see the roadmap](#️-roadmap)

</div>
