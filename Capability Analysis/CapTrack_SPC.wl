
---

# Sample WLanguage code (CapTrack_SPC.wl)

> This is **illustrative**: it uses common WL patterns and built-ins like `StatStandardDeviation` for clarity.

// ===============================================
// CapTrack – Capability & SPC (Core Procedures)
// WLanguage / WinDev
// ===============================================

// ---- Configuration (demo) ----
CONSTANT LSL = 9.5
CONSTANT USL = 10.5

// ---- Entry point (demo harness) ----
PROCEDURE CapTrack_Demo()
sCSVPath is string = fExeDir() + ["data\sample.csv"]
aVals is array of real dynamic = LoadValuesFromCSV(sCSVPath)

IF aVals..Occurrence = 0 THEN
	Info("No values loaded.")
	RETURN
END

st is STATS = ComputeStats(aVals)
cap is CAP = ComputeCapability(st, LSL, USL)
def is DEFECT = EstimateDefectsNormal(st, LSL, USL)

TraceCapability(st, cap, def)

sOutDir is string = fExeDir() + ["out\"]
fMakeDir(sOutDir)
sOutPng is string = sOutDir + "histogram.png"
IF ExportHistogram(aVals, LSL, USL, sOutPng) THEN
	Trace("Saved chart -> " + sOutPng)
END

// ---- Data structures ----
STRUCTURE STATS
	nCount is int
	mean is real
	stdev is real // sample standard deviation
END

STRUCTURE CAP
	pp is real // (USL - LSL) / (6 * stdev)
	ppk is real // min((USL-mean)/(3*stdev), (mean-LSL)/(3*stdev))
END

STRUCTURE DEFECT
	pBelow is real // probability or fraction below LSL
	pAbove is real // probability or fraction above USL
	pTotal is real
END

// ---- CSV loader (expects header 'value') ----
PROCEDURE LoadValuesFromCSV(sPath is string) : array of real dynamic
aResult is array of real dynamic
IF NOT fFileExist(sPath) THEN
	RETURN aResult
END

sAll is string = fLoadText(sPath, foAnsi)
IF sAll = "" THEN RETURN aResult

arrLines is array of string dynamic = StringSplit(sAll, CR)
bSkipHeader is boolean = True

FOR EACH sLine OF arrLines
	IF sLine = "" THEN CONTINUE
	IF bSkipHeader THEN
		bSkipHeader = False
		CONTINUE
	END
	// split by comma; simple CSV (no quotes) for demo
	arrCol is array of string dynamic = StringSplit(sLine, ",")
	IF arrCol..Occurrence >= 1 THEN
		v is real = Val(arrCol[1])
		IF v <> 0 OR arrCol[1] = "0" THEN
			ArrayAdd(aResult, v)
		END
	END
END

RETURN aResult

// ---- Basic statistics ----
PROCEDURE ComputeStats(aVals is array of real dynamic) : STATS
res is STATS
res.nCount = aVals..Occurrence
IF res.nCount <= 1 THEN
	res.mean = 0
	res.stdev = 0
	RETURN res
END

// Mean
sum is real = 0
FOR EACH v OF aVals
	sum += v
END
res.mean = sum / res.nCount

// Sample standard deviation (uses built-in if available)
res.stdev = StatStandardDeviation(aVals, sstSample) // WinDev: requires a REAL array

RETURN res

// ---- Capability indices ----
PROCEDURE ComputeCapability(st is STATS, lsl is real, usl is real) : CAP
c is CAP
IF st.stdev <= 0 THEN RETURN c
IF usl = 0 AND lsl = 0 THEN RETURN c

c.pp = (usl - lsl) / (6 * st.stdev)
ppu is real = (usl - st.mean) / (3 * st.stdev)
ppl is real = (st.mean - lsl) / (3 * st.stdev)
c.ppk = Min(ppu, ppl)

RETURN c

// ---- Normal CDF helper (approximation) ----
// Uses an ERF-based approximation for Φ(z). Good enough for reporting.
PROCEDURE Phi(z is real) : real
// Abramowitz & Stegun approximation
t is real = 1 / (1 + 0.2316419 * Abs(z))
d is real = 0.3989423 * Exp(-z*z / 2)
prob is real = 1 - d * (1.330274429*t - 1.821255978*t^2 + 1.781477937*t^3 - 0.356563782*t^4 + 0.319381530*t^5)
IF z < 0 THEN
	RETURN 1 - prob
ELSE
	RETURN prob
END

// ---- Defect estimation under normality assumption ----
PROCEDURE EstimateDefectsNormal(st is STATS, lsl is real, usl is real) : DEFECT
d is DEFECT
IF st.stdev <= 0 THEN RETURN d
zL is real = (lsl - st.mean) / st.stdev
zU is real = (usl - st.mean) / st.stdev
d.pBelow = Phi(zL)
d.pAbove = 1 - Phi(zU)
d.pTotal = d.pBelow + d.pAbove
RETURN d

// ---- Console-style trace ----
PROCEDURE TraceCapability(st is STATS, cap is CAP, def is DEFECT)
Trace("=== Capability Summary ===")
Trace("Count: " + st.nCount)
Trace(StringBuild("Mean (μ): %.5f", st.mean))
Trace(StringBuild("Std Dev (σ): %.5f", st.stdev))
Trace(StringBuild("LSL: %.4f   USL: %.4f", LSL, USL))
IF cap.pp > 0 THEN
	Trace(StringBuild("Pp:  %.3f", cap.pp))
ELSE
	Trace("Pp:  N/A")
END
IF cap.ppk > 0 THEN
	Trace(StringBuild("Ppk: %.3f", cap.ppk))
ELSE
	Trace("Ppk: N/A")
END
IF def.pTotal > 0 THEN
	Trace(StringBuild("Est. Defect Rate: %.4f%%", def.pTotal * 100.0))
ELSE
	Trace("Est. Defect Rate: N/A")
END

// ---- Simple histogram export (using charts) ----
// Requires a chart control or offscreen chart; here we sketch an offscreen approach.
// drop a Chart control and use ChartXYZ functions.
PROCEDURE ExportHistogram(aVals is array of real dynamic, lsl is real, usl is real, sOutPng is string) : boolean
// Pseudo-implementation outline; adapt to your charting setup:
nBins is int = 15
IF aVals..Occurrence = 0 THEN RETURN False

// Compute range and bins
vMin is real = aVals[1]
vMax is real = aVals[1]
FOR EACH v OF aVals
	IF v < vMin THEN vMin = v
	IF v > vMax THEN vMax = v
END
binWidth is real = (vMax - vMin) / nBins
IF binWidth <= 0 THEN binWidth = 1

aBins is array of int dynamic
ArrayResize(aBins, nBins)
FOR EACH v OF aVals
	idx is int = Max(1, Min(nBins, 1 + Floor((v - vMin) / binWidth)))
	aBins[idx] += 1
END

RETURN True
