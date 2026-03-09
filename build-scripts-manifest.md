# AI Lab Document Build Scripts — Source Manifest
# Version: March 2026
# Purpose: Enables reconstruction of build scripts in a new chat session
# Attach this alongside the target docx when asking Claude to update a document

---

## Overview

Three documents are maintained as Node.js build scripts using the `docx` npm package.
Each script generates a .docx file when run with `node SCRIPT.js`.
All scripts share the same helper function architecture with minor per-document variations.

**Documents and their scripts:**

| Document | Script | Current version |
|---|---|---|
| Lab_Implementation_Checklist | lab_checklist_v11.js | v1.8 |
| AI_Lab_VM_Maintenance_Guide | maintenance_v1.js | v1.3 |
| AI_Lab_Implementation_Plan | impl_v2.js | v2.9 |

---

## Environment

```bash
# Working directory
/home/claude/

# Output directory
/mnt/user-data/outputs/

# Build command
node SCRIPT_NAME.js

# Validate output
python3 /mnt/skills/public/docx/scripts/office/validate.py OUTPUT.docx

# Required npm package (install if missing)
npm install docx
```

---

## Shared Helper Architecture (all three scripts)

### Imports and color palette

```javascript
"use strict";
const {
  Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
  HeadingLevel, BorderStyle, WidthType, ShadingType, AlignmentType,
  LevelFormat, PageBreak
} = require("docx");
const fs = require("fs");

const C = {
  navy:"1F4E79", navyLight:"2E75B6",
  teal:"0E6655", tealLight:"D1F2EB",
  amber:"B7600A", amberLight:"FEF3E2",
  green:"1A7431", greenLight:"D5F5E3",
  red:"C0392B", redLight:"FADBD8",
  purple:"5B2C8D", purpleLight:"F0E6FA",
  silver:"F4F6F7", midGrey:"BDC3C7",
  white:"FFFFFF", charcoal:"2D2D2D",
  codeBg:"F0F0F0", outputBg:"E8F5E9",
};
```

### Typography helpers (shared across all scripts)

```javascript
const h1 = t => // Heading 1: navy, size 32, underline border
const h2 = t => // Heading 2: teal, size 26
const h3 = t => // Heading 3: charcoal bold, size 22
const para = t => // Body paragraph, size 22, Arial
const bull = t => // Bullet point, size 22 (uses numbering reference "bullets")
const sp = n  => // Array of n blank paragraphs — MUST use Array(n).fill(0).map(()=>new Paragraph(...))
                  // NEVER use Array(n).fill(paragraph) — creates n refs to same object, docx rejects it
const pb = ()  => // Page break
```

### Table helpers (shared)

```javascript
const cell = (text, width, fill=C.white, opts={}) => // TableCell with borders and padding
const hdrRow = (cols, widths) => // Navy header row, white bold text
const dataRow = (cols, widths, fill=C.white) => // Data row, alternating with C.silver for zebra
const tbl = (widths, rows) => // Full-width table, widths in DXA units, total = 9360
```

### Document assembly pattern (shared)

```javascript
const doc = new Document({
  numbering: { config: [
    { reference: "bullets", levels: [{ level:0, format:LevelFormat.BULLET, text:"•",
        alignment:AlignmentType.LEFT,
        style:{paragraph:{indent:{left:720,hanging:360}}} }] },
    { reference: "numbers", levels: [{ level:0, format:LevelFormat.DECIMAL, text:"%1.",
        alignment:AlignmentType.LEFT,
        style:{paragraph:{indent:{left:720,hanging:360}}} }] },
  ]},
  styles: {
    default: { document: { run: { font:"Arial", size:22 } } },
    paragraphStyles: [ /* Heading1 and Heading2 style definitions */ ],
  },
  sections: [{ properties: { page: { size:{width:12240,height:15840},
      margin:{top:1440,right:1440,bottom:1440,left:1440} } },
    children: [ ...allSections ],
  }],
});

Packer.toBuffer(doc).then(buf => {
  fs.writeFileSync("/mnt/user-data/outputs/FILENAME.docx", buf);
  console.log("Done.");
});
```

---

## Checklist Script — Additional Helpers

```javascript
// Code line types (color-coded)
const cmd = t => codeLine(t, "EBF5FB", "1A5276")  // blue bg — command you type
const out = t => codeLine(t, "E9F7EF", "1D6A38")  // green bg — expected output
const cmt = t => codeLine(t, C.codeBg, "777777")  // grey bg — comment/annotation

// Code block with label
const codeBlock = (label, lines) => [ labelParagraph, ...lines, ...sp(1) ]

// Callout boxes
const tip   = t => mkBox("💡 TIP",      C.teal,   C.tealLight,   t)
const warn  = t => mkBox("⚠ WARNING",   C.amber,  C.amberLight,  t)
const check = t => mkBox("✅ VERIFIED", C.green,  C.greenLight,  t)
const fail  = t => mkBox("🔴 IF FAIL",  C.red,    C.redLight,    t)
const deci  = t => mkBox("📌 DECISION", C.navy,   C.silver,      t)
const pend  = t => mkBox("🔲 PENDING",  C.purple, C.purpleLight, t)
// All callout functions spread: ...tip("text") not tip("text")
```

### Checklist section structure

```
secCover  — title page, changelog bullets, how to read
sec0      — §0  USB Passthrough Setup (one-time)
sec1      — §1  Current Lab State baseline verification
sec2      — §2  Task A: Model Library
sec3      — §3  Task B: KV Cache
sec4      — §4  Task C: Open WebUI
sec5      — §5  Task D: SSD Fast Tier + ollama-tier script
[sec6 removed — Task E Evdev, not part of setup]
sec7      — §6  Task E: Workspace Structure (cline-user, claude-code-user, bind mounts)
sec8      — §7  Task F: Git and GitHub
sec8b     — §8  Task G: Session Framework (RCD, new-session script)
sec9      — §9  Decisions: Model Routing
sec10     — §10 Session Execution Plan (Sessions A-D)
sec11     — §11 Deferred Phases
sec12     — §12 Document Changelog

Assembly: ...secCover, ...sec0, ...sec1, ...sec2, ...sec3, ...sec4, ...sec5,
           ...sec7, ...sec8, ...sec8b, ...sec9, ...sec10, ...sec11, ...sec12
```

---

## Maintenance Guide Script — Additional Helpers

```javascript
// Code block — table-based for alignment
const code = lines => new Table(...)  // lines are [text, colorConstant] pairs

// Color constants for code lines
const G = C.codeGreen   // command (green)
const W = C.codeWhite   // plain text / comment
const B = C.codeBlue    // expected output (blue)
const Y = C.codeYellow  // warning / important note

// Callout variants
const warn   = t => callout("⚠", "Warning", t, ...)
const tip    = t => callout("💡", "Tip", t, ...)
const danger = t => callout("🔴", "Critical", t, ...)
const note   = t => callout("📋", "Note", t, ...)
const ph     = t => callout("🔲", "Placeholder — Not Yet Documented", t, ...)
const warnM  = lines => calloutMulti(...)  // multi-line variant
const tipM   = lines => calloutMulti(...)
```

### Maintenance Guide section structure

```
s1  — §1  Quick Reference (access, VM lifecycle, Ollama & models)
s2  — §2  Host Maintenance (updates, Cockpit, SSH architecture, nginx, nftables)
s3  — §3  VM Maintenance (snapshots, lifecycle, updates, Ollama, tier mgmt, terminal env)
s4  — §4  GPU & Driver
s5  — §5  Storage
s6  — §6  Network
s7  — §7  Security
s8  — §8  Recovery Procedures (USB passthrough detach §8.6)
s9  — §9  Full Health Check
s10 — §10 Maintenance Calendar
s11 — §11 Document Changelog
```

---

## Implementation Plan Script — Additional Helpers

```javascript
// Mechanism and discovery callouts
const mech      = t     => callout("⚙", "Mechanism — What's happening under the hood", t, ...)
const found     = t     => callout("🔍", "What we discovered during the build", t, ...)
const mechMulti = lines => calloutMulti("⚙", "Mechanism...", lines, ...)
const foundMulti= lines => calloutMulti("🔍", "What we discovered...", lines, ...)

// Code block — similar to maintenance guide, uses [text, colorConstant] pairs
const code = lines => ...
```

### Implementation Plan structure (high level)

```
Chapter 1   — Project Context and Goals
Chapter 2   — Hardware Specification
Chapter 3   — Design Decisions
Chapter 4   — Phase 1: Host OS
Chapter 5   — Phase 2: IOMMU/VFIO
Chapter 6   — Phase 3: VM Creation
Chapter 7   — Phase 4: GPU Passthrough
Chapter 8   — Phase 5: SSH and Networking
Chapter 9   — Phase 6: Ollama + Storage Tiers (model-promote, ollama-tier §9.5)
Chapter 10  — Phase 7: Open WebUI
Chapter 11  — Phase 8: KV Cache / Model Config
Chapter 12  — Phase 9: Hardening and Autostart
Chapter 13  — RIIF Integration Design
Chapter 14  — Input Architecture (USB passthrough §14.4, §14.5)
Chapter 15  — Workspace and Agent Security (cline-user, claude-code-user)
Chapter 16  — Session Framework
Chapter 17  — Platform Evaluations (Proxmox, dual GPU)
Chapter 18  — Changelog (v2.1 through v2.9)
Final Architecture Summary — inline near end
```

---

## Key Rules for Reconstruction

1. **sp() must use map pattern** — `Array(n).fill(0).map(()=>new Paragraph(...))` not `Array(n).fill(paragraph)`
2. **Callout functions spread** — `...tip("text")` not `tip("text")` for checklist; maintenance/impl use direct call
3. **writeFileSync filename and changelog version must match** — change both together
4. **Total table width = 9360 DXA** — column widths must sum to 9360
5. **Validate after every build** — `python3 /mnt/skills/public/docx/scripts/office/validate.py OUTPUT.docx`
6. **Read SKILL.md before starting** — `/mnt/skills/public/docx/SKILL.md`

---

## How to Use This Manifest in a New Chat

1. Attach this manifest + the target docx to your first message
2. Say: "Update [section] in the attached document. Use the build script architecture described in the manifest."
3. Claude reads the docx for current content, reads the manifest for script architecture, writes a new build script, generates the updated docx
4. Download the output and keep for next session

For changelog entries: always add new entry at top, version number +0.1 from current, date "Mar 2026".
For section renumbering: update h1() text, assembly array order, and Session Execution Plan task ranges together.
