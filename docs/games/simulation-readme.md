# Enhanced Board Game Simulator

A lightweight Node.js simulation engine for rapid game balance testing across multiple strategic board games. Perfect for quick balance validation and statistical analysis during game development.

## 🎮 Supported Games

### Napoleonic Wars
- **Factions**: France, Britain, Austria, Russia, Prussia
- **Victory Types**: Military conquest, Political maneuvering
- **Target Balance**: Competitive multiplayer dynamics

### Alexander the Great
- **Factions**: Alexander, Persians, Egyptians, Indians
- **Victory Types**: Territorial expansion, Cultural influence
- **Target Balance**: Historical accuracy with strategic depth

### Gangsters
- **Factions**: Mafia, Irish Mob, Yakuza, Triads, NYPD
- **Victory Types**: Territory control, Cash accumulation
- **Target Balance**: NYPD as wild card faction

### LA Gang Wars
- **Factions**: Bloods, Crips, Mexican Mafia, LAPD
- **Victory Types**: Reputation dominance, Territory control
- **Target Balance**: Police vs gang equilibrium

## 🚀 Quick Start

### Prerequisites
```bash
node --version  # Requires Node.js 14+
```

### Installation
```bash
# Clone or download the simulator.js file
# No additional dependencies required
```

### Basic Usage
```bash
# Quick 100-game simulation
node simulator.js napoleonic

# Larger sample with analysis
node simulator.js gangsters 500 --analyze

# Full analysis with balance detection
node simulator.js la-gang-wars 1000 --analyze --detect-balance

# Export data for external analysis
node simulator.js alexander 750 --export-csv
```

## 📋 Command Reference

### Syntax
```
node simulator.js <game-type> [iterations] [players] [options]
```

### Parameters
- **game-type**: `napoleonic` | `alexander` | `gangsters` | `la-gang-wars`
- **iterations**: Number of games to simulate (default: 100)
- **players**: Player count (uses game defaults if omitted)

### Options
- `--analyze`: Show detailed statistical analysis
- `--export-csv`: Export results to timestamped CSV file
- `--detect-balance`: Identify potential balance issues

### Examples
```bash
# Basic simulation
node simulator.js napoleonic 200

# With player count specification
node simulator.js alexander 300 4

# Full analysis suite
node simulator.js gangsters 1000 5 --analyze --export-csv --detect-balance

# Quick balance check
node simulator.js la-gang-wars 500 --detect-balance
```

## 📊 Understanding Results

### Quick Results Format
```
=== QUICK RESULTS ===
France: 89/200 (44.5%)
Britain: 45/200 (22.5%)
Austria: 35/200 (17.5%)
Russia: 31/200 (15.5%)
```

### Detailed Analysis Output

#### Winner Distribution
Shows faction win rates and counts:
```
--- Winner Distribution ---
Mafia: 156 wins (31.2%)
Irish Mob: 134 wins (26.8%)
Yakuza: 98 wins (19.6%)
NYPD: 112 wins (22.4%)
```

#### Victory Type Distribution
Reveals strategic patterns:
```
--- Victory Type Distribution ---
territory: 267 games (53.4%)
cash: 233 games (46.6%)
```

#### Game-Specific Statistics
Provides contextual metrics:
```
--- Enhanced Game-Specific Stats ---
Coalition Formed: 73%
Cities Conquered: 18
Cash Laundered: $450,000
Territories Secured: 12
```

## 🎯 Balance Analysis

### Automatic Detection Thresholds
The simulator flags potential issues:

- **Dominant Faction**: Win rate >60%
- **Weak Faction**: Win rate <10% (in 50+ game samples)
- **Unbalanced Outcomes**: Consistent patterns suggesting mechanical issues

### Sample Balance Report
```
--- Balance Issues Detection ---
⚠️  Mafia wins too frequently: 67.2%
⚠️  Yakuza wins too frequently: 71.8%
✅ No major balance issues detected.
```

### Interpreting Balance Issues

**High Win Rates (>60%)**
- Faction may be overpowered
- Other factions may need buffs
- Victory conditions may favor this faction's strategy

**Low Win Rates (<10%)**
- Faction may be underpowered
- Starting conditions may be insufficient
- Victory conditions may be misaligned

**Extreme Outcomes**
- Indicates potential snowball effects
- May suggest first-player advantage
- Could reveal unintended faction synergies

## 📈 Statistical Analysis

### Sample Size Recommendations
- **Quick Testing**: 100-200 games
- **Balance Validation**: 500-1000 games
- **Statistical Significance**: 1000+ games
- **Publication Quality**: 2000+ games

### Confidence Intervals
With 1000+ simulations:
- Win rates accurate to ±3%
- Victory type distributions reliable
- Balance issues clearly identifiable

### Variance Analysis
Normal variance indicators:
- Win rate spread: 15-20% between factions
- Victory type split: 40-60% range acceptable
- Game length: Consistent within ±30% of average

## 📁 CSV Export Analysis

### File Format
Exported files include timestamp: `napoleonic_enhanced_simulation_500games_2024-01-15T14-30-45.csv`

### Column Structure
```csv
game,winner,turns,victoryType
napoleonic,France,15,military
napoleonic,Coalition,12,political
alexander,Alexander,8,territorial
```

### External Analysis Workflow
```bash
# Generate datasets
node simulator.js napoleonic 2000 --export-csv
node simulator.js alexander 1500 --export-csv
node simulator.js gangsters 1000 --export-csv
node simulator.js la-gang-wars 1000 --export-csv

# Files ready for R, Python, or Excel analysis
```

## 🔧 Advanced Usage

### Batch Testing
```bash
#!/bin/bash
# Test all games for balance
games=("napoleonic" "alexander" "gangsters" "la-gang-wars")
for game in "${games[@]}"; do
    echo "Testing $game..."
    node simulator.js $game 1000 --detect-balance
done
```

### Comparative Analysis
```bash
# Test different player counts
for players in 3 4 5; do
    node simulator.js napoleonic 500 $players --export-csv
done
```

### Statistical Validation
```bash
# Large sample for research
node simulator.js alexander 5000 --analyze --export-csv --detect-balance
```

## 🎲 Simulation Methodology

### Game Modeling
- **Randomized outcomes** with weighted probabilities
- **Faction-specific mechanics** reflecting unique abilities
- **Variable game length** based on strategic choices
- **Multiple victory conditions** promoting diverse strategies

### Statistical Reliability
- **Consistent random seeding** for reproducible results
- **Large sample support** for statistical significance
- **Outlier detection** in balance analysis
- **Confidence interval calculations** for win rate accuracy

### Validation Approach
- **Historical game data** comparison where available
- **Playtesting correlation** with simulation results
- **Balance threshold tuning** based on game design goals
- **Edge case identification** through large sample analysis

## 📝 Interpreting Game-Specific Results

### Napoleonic Wars
- **France dominance**: >50% may indicate coalition mechanics need strengthening
- **Coalition effectiveness**: Should form in majority of games
- **Victory type balance**: Military vs political paths should be viable

### Alexander the Great
- **Alexander survival**: High survival rates may indicate too easy expansion
- **Resistance success**: Persian/Indian victories show defensive viability
- **Territorial spread**: Average conquest levels indicate expansion balance

### Gangsters
- **NYPD impact**: 20-30% win rate suggests effective wild card role
- **Gang balance**: No single criminal faction should dominate consistently
- **Resource management**: Cash vs territory victories should be balanced

### LA Gang Wars
- **LAPD effectiveness**: Should compete without dominating
- **Gang warfare**: Territorial control should require sustained effort
- **Reputation mechanics**: Multiple paths to victory via respect/control

## 🔍 Troubleshooting

### Common Issues

**Unexpected Results**
```bash
# Increase sample size for stability
node simulator.js gangsters 2000 --analyze
```

**Performance Issues**
```bash
# Reduce iterations for quick testing
node simulator.js napoleonic 100
```

**File Permissions**
```bash
# Ensure write access for CSV export
chmod 755 .
```

### Performance Optimization
- Analysis adds ~20% processing time
- CSV export is lightweight
- Balance detection is computation-minimal
- Memory usage scales linearly with iterations

## 🎯 Design Guidelines

### Target Win Rate Ranges
- **Napoleonic**: France 40-50%, others 12-20% each
- **Alexander**: Alexander 45-55%, others 15-20% each  
- **Gangsters**: NYPD 20-30%, gangs 18-25% each
- **LA Gang Wars**: LAPD 25-35%, gangs 20-30% each

### Healthy Balance Indicators
- No faction >60% or <10% win rate
- Victory types within 40-60% distribution
- Game length variance <50% of average
- Multiple viable strategic approaches

### Red Flags
- Single faction >70% win rate
- Victory type >80% concentration
- Extreme game length variance
- Consistent early/late game advantages