# -----------------------------------------------------------------------------
# Update memory controller path in scripts
# -----------------------------------------------------------------------------

$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

$relativePaths = @("$MEMCTRL_DIR/ips/Xi_Phy/ip_setup.tcl", "$MEMCTRL_DIR/ips/Xi_BRAM/ip_setup.tcl")

foreach ($relativePath in $relativePaths) {
    $absPath = Join-Path $scriptPath $relativePath

    if (-Not (Test-Path $absPath)) {
        Write-Error "File not found: $absPath"
        exit 1
    }

    $fileContent = Get-Content $absPath

    $pattern = 'set MEMCTRL_DIR .+'
    $replacement = "set MEMCTRL_DIR $scriptPath"

    $fileContent = $fileContent -replace $pattern, $replacement

    $fileContent | Set-Content $absPath

    Write-Host "Path updated successfully in $absPath"
}

# -----------------------------------------------------------------------------
# Compile simulation libraries
# -----------------------------------------------------------------------------

#cd $MEMCTRL_DIR/ips/Xi_Phy/
#vivado -mode batch -source Sim_CompileLib.tcl

# -----------------------------------------------------------------------------
# Copy modelsim.ini files
# -----------------------------------------------------------------------------

Copy-Item -Path $SIM_LIB_PATH/compile_simlib/questasim/modelsim.ini -Destination $MEMCTRL_DIR/validation/tb_ddr4_ch_ctrl/
Copy-Item -Path $SIM_LIB_PATH/compile_simlib/questasim/modelsim.ini -Destination $MEMCTRL_DIR/validation/tb_ddr4_mem_ch_top/

# -----------------------------------------------------------------------------
# Synthesis Xilinx Phy
# -----------------------------------------------------------------------------

cd $MEMCTRL_DIR/ips/Xi_Phy/
vivado -mode batch -source Mig_phy_only_ip.tcl

# -----------------------------------------------------------------------------
# Synthesis Xilinx BRAMs
# -----------------------------------------------------------------------------

cd $MEMCTRL_DIR/ips/Xi_BRAM

vivado -mode batch -source BRAM_512x64.tcl
vivado -mode batch -source BRAM_52x4.tcl
vivado -mode batch -source BRAM_528x64.tcl
vivado -mode batch -source BRAM_528x8.tcl

# -----------------------------------------------------------------------------
# Wait until synthesis is done
# -----------------------------------------------------------------------------

# $synthDoneFiles = @(
#     "$MEMCTRL_DIR/ips/Xi_Phy/IP/mig_phy/mig_phy.runs/ddr4_0_synth_1/__synthesis_is_complete__",
#     "$MEMCTRL_DIR/ips/IP/bram_52x4/bram_52x4.runs/blk_mem_gen_52x4_synth_1/__synthesis_is_complete__",
#     "$MEMCTRL_DIR/ips/IP/bram_512x64/bram.runs/blk_mem_gen_0_synth_1/__synthesis_is_complete__",
#     "$MEMCTRL_DIR/ips/Xi_BRAM/IP/bram_528x8/bram_528x8.runs/blk_mem_gen_528x8_synth_1/__synthesis_is_complete__",
#     "$MEMCTRL_DIR/ips/Xi_BRAM/IP/bram_528x64/bram_528x64.runs/blk_mem_gen_528x64_synth_1/__synthesis_is_complete__"
# )

# $allSynthDone = $false

# while (-not $allSynthDone) {
#     $allSynthDone = $synthDoneFiles | ForEach-Object { Test-Path (Join-Path $directory $_) } | Where-Object { -not $_ } | Measure-Object | Select-Object -ExpandProperty Count -eq 0
#     if (-not $allSynthDone) {
#         Write-Host "Waiting for all IPs to synthesize..."
#         Start-Sleep -Seconds 5  # Wait for 5 seconds before checking again
#     }
# }

# Write-Host "IPs synthesis completed! Proceeding..."

# -----------------------------------------------------------------------------
# Run simulation
# -----------------------------------------------------------------------------

cd $MEMCTRL_DIR/validation/tb_ddr4_mem_ch_top/

# vsim -c -do ./run.tcl
