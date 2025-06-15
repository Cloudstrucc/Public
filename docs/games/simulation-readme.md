## 📊 **Features**

### **Game Simulations**

* **Napoleonic Wars** : Models coalition dynamics, French expansion, seasonal effects
* **Alexander the Great** : Includes loyalty systems, succession crises, supply challenges
* **Gangsters** : Corruption vs trust mechanics, police raids, prohibition economics
* **LA Gang Wars** : Gang warfare, respect systems, LAPD operations

### **Analysis & Balance Detection**

* **Winner distribution** with percentages
* **Victory type analysis**
* **Game length statistics**
* **Faction-specific metrics**
* **Automatic balance issue detection**

### **Export & Documentation**

* **CSV export** for detailed analysis
* **Command-line interface** with multiple options
* **Real-time progress tracking**
* **Timestamp tracking** for result correlation

## 🚀 **Usage Examples**

``` bash
# Basic simulation
node simulator.js napoleonic 100

# Detailed analysis with balance detection
node simulator.js alexander 200 4 --analyze --detect-balance

# Export results for external analysis
node simulator.js gangsters 500 5 --export-csv

# Full analysis with CSV export
node simulator.js la-gang-wars 150 --analyze --export-csv --detect-balance
```

## 📈 **Sample Output**

The simulator will detect issues like:

* ⚠️ France has a very high win rate (73%) - possible balance issue
* ⚠️ Alexander dies too frequently - mortality rate too high
* ⚠️ Games are very short (8 turns average) - possibly too decisive

## 🔧 **Installation**

1. Save the code as `simulator.js`
2. Run: `npm init -y && npm install` (no dependencies needed)
3. Make executable: `chmod +x simulator.js`
4. Run simulations: `node simulator.js napoleonic 100 --analyze`

## 📊 **CSV Output**

Each simulation generates detailed CSV files with columns like:

* `winner`, `victoryType`, `gameLength`
* `frenchTerritories`, `coalitionSize` (Napoleonic)
* `alexanderAlive`, `macedonTerritories` (Alexander)
* `nypd_corruption`, `nypd_trust` (Gangsters)
* `total_respect`, `total_heat` (LA Gang Wars)

This will help you identify:

* **Overpowered factions** (>60% win rate)
* **Underpowered factions** (<10% win rate)
* **Game length issues** (too short/long)
* **Faction-specific balance problems**
