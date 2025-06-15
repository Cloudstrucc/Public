#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

class GameSimulator {
    constructor() {
        this.results = [];
        this.gameTypes = ['napoleonic', 'alexander', 'gangsters', 'la-gang-wars'];
    }

    // Utility functions
    rollDice(sides = 6) {
        return Math.floor(Math.random() * sides) + 1;
    }

    rollMultipleDice(count, sides = 6) {
        return Array.from({length: count}, () => this.rollDice(sides));
    }

    calculateHits(attackValue, diceRolls) {
        return diceRolls.filter(roll => roll <= attackValue).length;
    }

    // Napoleonic Wars Simulation
    simulateNapoleonicWars(playerCount = 5) {
        const factions = ['France', 'Austria', 'Prussia', 'Russia', 'Britain'];
        const players = factions.slice(0, playerCount);
        
        const gameState = {
            turn: 1,
            season: 'Spring',
            year: 1805,
            players: {},
            winner: null,
            victoryType: null,
            gameLength: 0
        };

        // Initialize players
        players.forEach(faction => {
            gameState.players[faction] = {
                name: faction,
                territories: this.getStartingTerritories(faction),
                ipcs: this.getStartingIPCs(faction),
                units: this.getStartingUnits(faction),
                heat: faction === 'France' ? 2 : 0,
                coalitionStatus: faction !== 'France' ? 'Allied' : 'Independent'
            };
        });

        // Game loop
        while (gameState.turn <= 40 && !gameState.winner) {
            this.executeNapoleonicTurn(gameState);
            gameState.turn++;
            
            // Update season every 4 turns
            if (gameState.turn % 4 === 1) {
                gameState.year++;
                gameState.season = ['Spring', 'Summer', 'Autumn', 'Winter'][Math.floor((gameState.turn - 1) / 4) % 4];
            }

            // Check victory conditions
            this.checkNapoleonicVictory(gameState);
        }

        gameState.gameLength = gameState.turn;
        return this.formatNapoleonicResults(gameState);
    }

    executeNapoleonicTurn(gameState) {
        const turnOrder = ['France', 'Austria', 'Prussia', 'Russia', 'Britain'];
        
        turnOrder.forEach(faction => {
            if (gameState.players[faction] && !gameState.winner) {
                this.executePlayerTurn(gameState, faction);
            }
        });

        // Random events
        if (this.rollDice() === 6) {
            this.triggerNapoleonicEvent(gameState);
        }
    }

    executePlayerTurn(gameState, faction) {
        const player = gameState.players[faction];
        
        // Income phase
        player.ipcs += player.territories * 2 + this.rollDice();
        
        // Spending phase
        const spendBudget = Math.floor(player.ipcs * 0.7);
        player.ipcs -= spendBudget;
        
        // Military actions
        if (faction === 'France') {
            this.executeFrenchStrategy(gameState, player);
        } else {
            this.executeCoalitionStrategy(gameState, player, faction);
        }

        // Combat resolution
        this.resolveCombats(gameState, faction);
    }

    executeFrenchStrategy(gameState, player) {
        // Aggressive expansion strategy
        const expansionChance = Math.max(0.3, 0.7 - (gameState.turn / 40));
        
        if (Math.random() < expansionChance) {
            // Attempt territory expansion
            const targetTerritories = Math.floor(Math.random() * 3) + 1;
            player.territories += targetTerritories;
            player.heat += targetTerritories;
            
            // Coalition response
            Object.values(gameState.players).forEach(p => {
                if (p.name !== 'France' && p.coalitionStatus === 'Allied') {
                    p.units += Math.floor(Math.random() * 2);
                }
            });
        }
    }

    executeCoalitionStrategy(gameState, player, faction) {
        // Defensive/coalition building strategy
        if (gameState.players.France.territories > 20) {
            player.units += Math.floor(Math.random() * 3) + 1;
            player.coalitionStatus = 'Allied';
        }

        // Naval strategy for Britain
        if (faction === 'Britain') {
            if (Math.random() < 0.4) {
                gameState.players.France.ipcs = Math.max(0, gameState.players.France.ipcs - this.rollDice() * 2);
            }
        }
    }

    resolveCombats(gameState, faction) {
        // Simplified combat resolution
        if (Math.random() < 0.3) { // 30% chance of combat each turn
            const combatResult = this.rollDice();
            const player = gameState.players[faction];
            
            if (combatResult >= 4) {
                player.territories += 1;
                player.units = Math.max(1, player.units - 1);
            } else {
                player.units = Math.max(1, player.units - Math.floor(Math.random() * 2));
            }
        }
    }

    checkNapoleonicVictory(gameState) {
        const france = gameState.players.France;
        
        // French victory conditions
        if (france.territories >= 25) {
            gameState.winner = 'France';
            gameState.victoryType = 'Territorial Domination';
            return;
        }

        // Coalition victory conditions
        if (france.territories <= 10) {
            gameState.winner = 'Coalition';
            gameState.victoryType = 'French Collapse';
            return;
        }

        // Time victory (historical)
        if (gameState.turn >= 40) {
            if (france.territories >= 15) {
                gameState.winner = 'France';
                gameState.victoryType = 'Historical Survival';
            } else {
                gameState.winner = 'Coalition';
                gameState.victoryType = 'Historical Victory';
            }
        }
    }

    // Alexander the Great Simulation
    simulateAlexanderConquest(playerCount = 4) {
        const factions = ['Macedon', 'Persian Empire', 'Greek City-States', 'Indian Kingdoms'];
        const players = factions.slice(0, playerCount);
        
        const gameState = {
            turn: 1,
            players: {},
            winner: null,
            victoryType: null,
            gameLength: 0,
            alexanderAlive: true
        };

        // Initialize players
        players.forEach(faction => {
            gameState.players[faction] = {
                name: faction,
                territories: this.getAlexanderStartingTerritories(faction),
                talents: this.getAlexanderStartingTalents(faction),
                units: this.getAlexanderStartingUnits(faction),
                loyalty: faction === 'Macedon' ? 5 : 3
            };
        });

        // Game loop
        while (gameState.turn <= 40 && !gameState.winner) {
            this.executeAlexanderTurn(gameState);
            gameState.turn++;
            this.checkAlexanderVictory(gameState);
        }

        gameState.gameLength = gameState.turn;
        return this.formatAlexanderResults(gameState);
    }

    executeAlexanderTurn(gameState) {
        const turnOrder = ['Macedon', 'Persian Empire', 'Greek City-States', 'Indian Kingdoms'];
        
        turnOrder.forEach(faction => {
            if (gameState.players[faction] && !gameState.winner) {
                this.executeAlexanderPlayerTurn(gameState, faction);
            }
        });

        // Alexander mortality check
        if (gameState.turn > 20 && Math.random() < 0.05) {
            gameState.alexanderAlive = false;
            this.triggerSuccessionCrisis(gameState);
        }
    }

    executeAlexanderPlayerTurn(gameState, faction) {
        const player = gameState.players[faction];
        
        // Income phase
        player.talents += player.territories * 3 + this.rollDice() * 2;
        
        if (faction === 'Macedon') {
            this.executeMacedonianStrategy(gameState, player);
        } else {
            this.executeResistanceStrategy(gameState, player, faction);
        }
    }

    executeMacedonianStrategy(gameState, player) {
        if (gameState.alexanderAlive) {
            // Aggressive conquest
            const conquestAttempts = Math.floor(Math.random() * 3) + 1;
            for (let i = 0; i < conquestAttempts; i++) {
                if (Math.random() < 0.6) {
                    player.territories += 1;
                    player.talents += this.rollDice() * 10; // Plunder
                }
            }
            
            // Supply line challenges
            if (player.territories > 25) {
                player.units = Math.max(1, player.units - Math.floor(Math.random() * 2));
            }
        }
    }

    executeResistanceStrategy(gameState, player, faction) {
        // Defensive strategy
        if (gameState.players.Macedon.territories > 15) {
            player.units += Math.floor(Math.random() * 2) + 1;
        }

        // Special abilities
        if (faction === 'Persian Empire') {
            // Satrap loyalty issues
            if (Math.random() < 0.2) {
                player.loyalty = Math.max(1, player.loyalty - 1);
                player.territories = Math.max(1, player.territories - 1);
            }
        }
    }

    checkAlexanderVictory(gameState) {
        const macedon = gameState.players.Macedon;
        
        if (!gameState.alexanderAlive) {
            gameState.winner = 'Diadochi';
            gameState.victoryType = 'Succession Crisis';
            return;
        }

        if (macedon.territories >= 30) {
            gameState.winner = 'Macedon';
            gameState.victoryType = 'World Conquest';
            return;
        }

        if (gameState.turn >= 40) {
            const largestEmpire = Object.values(gameState.players)
                .reduce((max, player) => player.territories > max.territories ? player : max);
            gameState.winner = largestEmpire.name;
            gameState.victoryType = 'Time Victory';
        }
    }

    // Gangsters Simulation
    simulateGangsters(playerCount = 5) {
        const factions = ['Irish Mob', 'Italian Famiglia', 'Jewish Syndicate', 'Polish Gang', 'NYPD'];
        const players = factions.slice(0, playerCount);
        
        const gameState = {
            turn: 1,
            players: {},
            winner: null,
            victoryType: null,
            gameLength: 0,
            prohibitionActive: true
        };

        // Initialize players
        players.forEach(faction => {
            gameState.players[faction] = {
                name: faction,
                territories: faction === 'NYPD' ? 2 : Math.floor(Math.random() * 3) + 2,
                money: this.getGangsterStartingMoney(faction),
                units: Math.floor(Math.random() * 5) + 3,
                heat: faction === 'NYPD' ? 0 : Math.floor(Math.random() * 3) + 1,
                corruption: faction === 'NYPD' ? 0 : Math.floor(Math.random() * 5) + 5,
                trust: faction === 'NYPD' ? 10 : 0
            };
        });

        // Game loop
        while (gameState.turn <= 30 && !gameState.winner) {
            this.executeGangsterTurn(gameState);
            gameState.turn++;
            this.checkGangsterVictory(gameState);
        }

        gameState.gameLength = gameState.turn;
        return this.formatGangsterResults(gameState);
    }

    executeGangsterTurn(gameState) {
        Object.keys(gameState.players).forEach(faction => {
            if (!gameState.winner) {
                this.executeGangsterPlayerTurn(gameState, faction);
            }
        });

        // Police raids
        if (gameState.players.NYPD && Math.random() < 0.4) {
            this.executePoliceRaid(gameState);
        }
    }

    executeGangsterPlayerTurn(gameState, faction) {
        const player = gameState.players[faction];
        
        // Income phase
        if (faction === 'NYPD') {
            player.money += 2000 + (player.trust * 100);
        } else {
            player.money += player.territories * 500 + this.rollDice() * 200;
            player.heat += Math.floor(player.territories / 3);
        }

        // Strategy execution
        if (faction === 'NYPD') {
            this.executePoliceStrategy(gameState, player);
        } else {
            this.executeGangStrategy(gameState, player, faction);
        }
    }

    executePoliceStrategy(gameState, player) {
        // Choose between honest and corrupt policing
        if (player.corruption < 5) {
            // Honest policing
            if (Math.random() < 0.7) {
                player.trust += 1;
                // Target highest heat gang
                const targetGang = Object.values(gameState.players)
                    .filter(p => p.name !== 'NYPD')
                    .reduce((max, p) => p.heat > max.heat ? p : max);
                if (targetGang) {
                    targetGang.heat += 2;
                    targetGang.units = Math.max(1, targetGang.units - 1);
                }
            }
        } else {
            // Corrupt policing
            if (Math.random() < 0.5) {
                player.corruption += 1;
                player.money += this.rollDice() * 500;
            }
        }
    }

    executeGangStrategy(gameState, player, faction) {
        // Expansion attempts
        if (Math.random() < 0.4) {
            player.territories += 1;
            player.heat += 1;
        }

        // Bribery attempts
        if (gameState.players.NYPD && Math.random() < 0.3) {
            const bribeCost = this.rollDice() * 500;
            if (player.money >= bribeCost) {
                player.money -= bribeCost;
                player.heat = Math.max(0, player.heat - 1);
                gameState.players.NYPD.corruption += 1;
            }
        }
    }

    executePoliceRaid(gameState) {
        const targets = Object.values(gameState.players)
            .filter(p => p.name !== 'NYPD' && p.heat > 3);
        
        if (targets.length > 0) {
            const target = targets[Math.floor(Math.random() * targets.length)];
            const raidSuccess = this.rollDice() + gameState.players.NYPD.trust;
            
            if (raidSuccess >= 8) {
                target.units = Math.max(1, target.units - Math.floor(Math.random() * 2));
                target.money = Math.max(0, target.money - this.rollDice() * 1000);
                target.heat = Math.max(0, target.heat - 2);
            }
        }
    }

    checkGangsterVictory(gameState) {
        // Check for gang victories
        Object.values(gameState.players).forEach(player => {
            if (player.name !== 'NYPD') {
                if (player.territories >= 12) {
                    gameState.winner = player.name;
                    gameState.victoryType = 'Territorial Control';
                    return;
                }
                if (player.money >= 20000) {
                    gameState.winner = player.name;
                    gameState.victoryType = 'Economic Victory';
                    return;
                }
            }
        });

        // Check for police victory
        if (gameState.players.NYPD) {
            const remainingGangs = Object.values(gameState.players)
                .filter(p => p.name !== 'NYPD' && p.territories > 0);
            
            if (remainingGangs.length <= 1) {
                gameState.winner = 'NYPD';
                gameState.victoryType = 'Law and Order';
            }
        }

        // Time victory
        if (gameState.turn >= 30) {
            const winner = Object.values(gameState.players)
                .reduce((max, player) => {
                    const score = player.territories * 1000 + player.money;
                    const maxScore = max.territories * 1000 + max.money;
                    return score > maxScore ? player : max;
                });
            gameState.winner = winner.name;
            gameState.victoryType = 'Time Victory';
        }
    }

    // LA Gang Wars Simulation
    simulateLAGangWars(playerCount = 4) {
        const factions = ['Bloods', 'Crips', 'Mexican Mafia', 'LAPD'];
        const players = factions.slice(0, playerCount);
        
        const gameState = {
            turn: 1,
            players: {},
            winner: null,
            victoryType: null,
            gameLength: 0
        };

        // Initialize players
        players.forEach(faction => {
            gameState.players[faction] = {
                name: faction,
                territories: faction === 'LAPD' ? 1 : Math.floor(Math.random() * 3) + 2,
                money: faction === 'LAPD' ? 5000 : 3000 + Math.random() * 1000,
                units: Math.floor(Math.random() * 4) + 3,
                respect: faction === 'LAPD' ? 0 : Math.floor(Math.random() * 10) + 5,
                heat: faction === 'LAPD' ? 0 : Math.floor(Math.random() * 4) + 2
            };
        });

        // Game loop
        while (gameState.turn <= 25 && !gameState.winner) {
            this.executeLAGangTurn(gameState);
            gameState.turn++;
            this.checkLAGangVictory(gameState);
        }

        gameState.gameLength = gameState.turn;
        return this.formatLAGangResults(gameState);
    }

    executeLAGangTurn(gameState) {
        Object.keys(gameState.players).forEach(faction => {
            if (!gameState.winner) {
                this.executeLAGangPlayerTurn(gameState, faction);
            }
        });
    }

    executeLAGangPlayerTurn(gameState, faction) {
        const player = gameState.players[faction];
        
        // Income phase
        if (faction === 'LAPD') {
            player.money += 2500;
        } else {
            player.money += player.territories * 400 + this.rollDice() * 200;
        }

        // Gang warfare
        if (faction !== 'LAPD' && Math.random() < 0.5) {
            this.executeGangWarfare(gameState, faction);
        }

        // LAPD operations
        if (faction === 'LAPD') {
            this.executeLAPDOperations(gameState);
        }
    }

    executeGangWarfare(gameState, faction) {
        const rivals = Object.keys(gameState.players).filter(f => f !== faction && f !== 'LAPD');
        if (rivals.length > 0) {
            const target = rivals[Math.floor(Math.random() * rivals.length)];
            const attacker = gameState.players[faction];
            const defender = gameState.players[target];
            
            const attackRoll = this.rollDice() + Math.floor(attacker.units / 2);
            const defenseRoll = this.rollDice() + Math.floor(defender.units / 2);
            
            if (attackRoll > defenseRoll) {
                attacker.territories += 1;
                attacker.respect += 2;
                defender.territories = Math.max(1, defender.territories - 1);
                defender.respect = Math.max(0, defender.respect - 1);
            } else {
                attacker.units = Math.max(1, attacker.units - 1);
                defender.respect += 1;
            }
            
            attacker.heat += 1;
            defender.heat += 1;
        }
    }

    executeLAPDOperations(gameState) {
        // Target highest heat gang
        const gangs = Object.values(gameState.players).filter(p => p.name !== 'LAPD');
        const target = gangs.reduce((max, gang) => gang.heat > max.heat ? gang : max);
        
        if (target && Math.random() < 0.6) {
            target.heat = Math.max(0, target.heat - 2);
            target.units = Math.max(1, target.units - 1);
            if (Math.random() < 0.3) {
                target.money = Math.max(0, target.money - this.rollDice() * 500);
            }
        }
    }

    checkLAGangVictory(gameState) {
        // Gang victory conditions
        Object.values(gameState.players).forEach(player => {
            if (player.name !== 'LAPD') {
                if (player.territories >= 8) {
                    gameState.winner = player.name;
                    gameState.victoryType = 'Territorial Control';
                    return;
                }
                if (player.respect >= 50) {
                    gameState.winner = player.name;
                    gameState.victoryType = 'Street Respect';
                    return;
                }
            }
        });

        // LAPD victory
        if (gameState.players.LAPD) {
            const totalGangHeat = Object.values(gameState.players)
                .filter(p => p.name !== 'LAPD')
                .reduce((sum, p) => sum + p.heat, 0);
            
            if (totalGangHeat <= 3) {
                gameState.winner = 'LAPD';
                gameState.victoryType = 'Peace in Compton';
            }
        }

        // Time victory
        if (gameState.turn >= 25) {
            const winner = Object.values(gameState.players)
                .reduce((max, player) => {
                    const score = player.territories * 2 + (player.respect || 0) + Math.floor(player.money / 1000);
                    const maxScore = max.territories * 2 + (max.respect || 0) + Math.floor(max.money / 1000);
                    return score > maxScore ? player : max;
                });
            gameState.winner = winner.name;
            gameState.victoryType = 'Time Victory';
        }
    }

    // Helper functions for starting conditions
    getStartingTerritories(faction) {
        const territories = {
            'France': 18,
            'Austria': 14,
            'Prussia': 8,
            'Russia': 22,
            'Britain': 12
        };
        return territories[faction] || 10;
    }

    getStartingIPCs(faction) {
        const ipcs = {
            'France': 35,
            'Austria': 25,
            'Prussia': 20,
            'Russia': 30,
            'Britain': 40
        };
        return ipcs[faction] || 20;
    }

    getStartingUnits(faction) {
        return Math.floor(Math.random() * 5) + 8;
    }

    getAlexanderStartingTerritories(faction) {
        const territories = {
            'Macedon': 8,
            'Persian Empire': 25,
            'Greek City-States': 12,
            'Indian Kingdoms': 12
        };
        return territories[faction] || 8;
    }

    getAlexanderStartingTalents(faction) {
        const talents = {
            'Macedon': 25,
            'Persian Empire': 60,
            'Greek City-States': 35,
            'Indian Kingdoms': 30
        };
        return talents[faction] || 20;
    }

    getAlexanderStartingUnits(faction) {
        return Math.floor(Math.random() * 4) + 6;
    }

    getGangsterStartingMoney(faction) {
        const money = {
            'Irish Mob': 4000,
            'Italian Famiglia': 5000,
            'Jewish Syndicate': 4500,
            'Polish Gang': 3500,
            'NYPD': 4000
        };
        return money[faction] || 4000;
    }

    // Result formatting functions
    formatNapoleonicResults(gameState) {
        return {
            game: 'Napoleonic Wars',
            winner: gameState.winner,
            victoryType: gameState.victoryType,
            gameLength: gameState.gameLength,
            finalYear: gameState.year,
            frenchTerritories: gameState.players.France?.territories || 0,
            frenchIPCs: gameState.players.France?.ipcs || 0,
            coalitionSize: Object.values(gameState.players).filter(p => p.coalitionStatus === 'Allied').length,
            playerCount: Object.keys(gameState.players).length,
            timestamp: new Date().toISOString()
        };
    }

    formatAlexanderResults(gameState) {
        return {
            game: 'Alexander the Great',
            winner: gameState.winner,
            victoryType: gameState.victoryType,
            gameLength: gameState.gameLength,
            alexanderAlive: gameState.alexanderAlive,
            macedonTerritories: gameState.players.Macedon?.territories || 0,
            macedonTalents: gameState.players.Macedon?.talents || 0,
            persianTerritories: gameState.players['Persian Empire']?.territories || 0,
            playerCount: Object.keys(gameState.players).length,
            timestamp: new Date().toISOString()
        };
    }

    formatGangsterResults(gameState) {
        return {
            game: 'Gangsters',
            winner: gameState.winner,
            victoryType: gameState.victoryType,
            gameLength: gameState.gameLength,
            nypd_corruption: gameState.players.NYPD?.corruption || 0,
            nypd_trust: gameState.players.NYPD?.trust || 0,
            total_territories: Object.values(gameState.players).reduce((sum, p) => sum + p.territories, 0),
            playerCount: Object.keys(gameState.players).length,
            timestamp: new Date().toISOString()
        };
    }

    formatLAGangResults(gameState) {
        return {
            game: 'LA Gang Wars',
            winner: gameState.winner,
            victoryType: gameState.victoryType,
            gameLength: gameState.gameLength,
            total_respect: Object.values(gameState.players).reduce((sum, p) => sum + (p.respect || 0), 0),
            total_heat: Object.values(gameState.players).filter(p => p.name !== 'LAPD').reduce((sum, p) => sum + p.heat, 0),
            lapd_active: !!gameState.players.LAPD,
            playerCount: Object.keys(gameState.players).length,
            timestamp: new Date().toISOString()
        };
    }

    // Random event triggers
    triggerNapoleonicEvent(gameState) {
        const events = ['harsh_winter', 'plague', 'good_harvest', 'diplomatic_crisis', 'technological_breakthrough'];
        const event = events[Math.floor(Math.random() * events.length)];
        
        switch(event) {
            case 'harsh_winter':
                Object.values(gameState.players).forEach(p => p.units = Math.max(1, p.units - 1));
                break;
            case 'plague':
                Object.values(gameState.players).forEach(p => p.units = Math.max(1, p.units - 1));
                break;
            case 'good_harvest':
                Object.values(gameState.players).forEach(p => p.ipcs += 200);
                break;
            case 'diplomatic_crisis':
                // Break alliances
                Object.values(gameState.players).forEach(p => p.coalitionStatus = 'Independent');
                break;
            case 'technological_breakthrough':
                const beneficiary = Object.keys(gameState.players)[Math.floor(Math.random() * Object.keys(gameState.players).length)];
                gameState.players[beneficiary].units += 2;
                break;
        }
    }

    triggerSuccessionCrisis(gameState) {
        if (gameState.players.Macedon) {
            gameState.players.Macedon.territories = Math.floor(gameState.players.Macedon.territories / 2);
            gameState.players.Macedon.units = Math.floor(gameState.players.Macedon.units / 2);
        }
    }

    // Main simulation runner
    runSimulations(gameType, iterations = 100, playerCount = null) {
        console.log(`Running ${iterations} simulations of ${gameType}...`);
        const results = [];
        
        for (let i = 0; i < iterations; i++) {
            let result;
            switch(gameType) {
                case 'napoleonic':
                    result = this.simulateNapoleonicWars(playerCount || 5);
                    break;
                case 'alexander':
                    result = this.simulateAlexanderConquest(playerCount || 4);
                    break;
                case 'gangsters':
                    result = this.simulateGangsters(playerCount || 5);
                    break;
                case 'la-gang-wars':
                    result = this.simulateLAGangWars(playerCount || 4);
                    break;
                default:
                    throw new Error(`Unknown game type: ${gameType}`);
            }
            results.push(result);
            
            if ((i + 1) % 10 === 0) {
                console.log(`Completed ${i + 1}/${iterations} simulations`);
            }
        }
        
        return results;
    }

    // CSV export functionality
    exportToCSV(results, filename) {
        if (results.length === 0) {
            console.log('No results to export');
            return;
        }

        // Get all unique keys from results
        const headers = [...new Set(results.flatMap(Object.keys))];
        
        // Create CSV content
        const csvContent = [
            headers.join(','),
            ...results.map(result => 
                headers.map(header => {
                    const value = result[header];
                    // Escape commas and quotes in values
                    if (typeof value === 'string' && (value.includes(',') || value.includes('"'))) {
                        return `"${value.replace(/"/g, '""')}"`;
                    }
                    return value || '';
                }).join(',')
            )
        ].join('\n');

        // Write to file
        fs.writeFileSync(filename, csvContent);
        console.log(`Results exported to ${filename}`);
    }

    // Analysis functions
    analyzeResults(results) {
        if (results.length === 0) {
            console.log('No results to analyze');
            return;
        }

        const analysis = {
            totalGames: results.length,
            winnerDistribution: {},
            victoryTypeDistribution: {},
            averageGameLength: 0,
            gameSpecificStats: {}
        };

        // Calculate winner distribution
        results.forEach(result => {
            analysis.winnerDistribution[result.winner] = (analysis.winnerDistribution[result.winner] || 0) + 1;
            analysis.victoryTypeDistribution[result.victoryType] = (analysis.victoryTypeDistribution[result.victoryType] || 0) + 1;
        });

        // Calculate percentages
        Object.keys(analysis.winnerDistribution).forEach(winner => {
            analysis.winnerDistribution[winner] = {
                count: analysis.winnerDistribution[winner],
                percentage: ((analysis.winnerDistribution[winner] / results.length) * 100).toFixed(2)
            };
        });

        Object.keys(analysis.victoryTypeDistribution).forEach(type => {
            analysis.victoryTypeDistribution[type] = {
                count: analysis.victoryTypeDistribution[type],
                percentage: ((analysis.victoryTypeDistribution[type] / results.length) * 100).toFixed(2)
            };
        });

        // Calculate average game length
        analysis.averageGameLength = (results.reduce((sum, r) => sum + r.gameLength, 0) / results.length).toFixed(2);

        // Game-specific analysis
        const gameType = results[0].game;
        switch(gameType) {
            case 'Napoleonic Wars':
                analysis.gameSpecificStats = this.analyzeNapoleonicStats(results);
                break;
            case 'Alexander the Great':
                analysis.gameSpecificStats = this.analyzeAlexanderStats(results);
                break;
            case 'Gangsters':
                analysis.gameSpecificStats = this.analyzeGangsterStats(results);
                break;
            case 'LA Gang Wars':
                analysis.gameSpecificStats = this.analyzeLAGangStats(results);
                break;
        }

        return analysis;
    }

    analyzeNapoleonicStats(results) {
        const frenchWins = results.filter(r => r.winner === 'France');
        const coalitionWins = results.filter(r => r.winner === 'Coalition');
        
        return {
            frenchWinRate: ((frenchWins.length / results.length) * 100).toFixed(2) + '%',
            averageFrenchTerritories: (results.reduce((sum, r) => sum + r.frenchTerritories, 0) / results.length).toFixed(2),
            averageCoalitionSize: (results.reduce((sum, r) => sum + r.coalitionSize, 0) / results.length).toFixed(2),
            gamesEndingEarly: results.filter(r => r.gameLength < 30).length,
            averageGameYear: (results.reduce((sum, r) => sum + r.finalYear, 0) / results.length).toFixed(1)
        };
    }

    analyzeAlexanderStats(results) {
        const alexanderSurvival = results.filter(r => r.alexanderAlive).length;
        const macedonWins = results.filter(r => r.winner === 'Macedon');
        
        return {
            alexanderSurvivalRate: ((alexanderSurvival / results.length) * 100).toFixed(2) + '%',
            macedonWinRate: ((macedonWins.length / results.length) * 100).toFixed(2) + '%',
            averageMacedonTerritories: (results.reduce((sum, r) => sum + r.macedonTerritories, 0) / results.length).toFixed(2),
            averagePersianTerritories: (results.reduce((sum, r) => sum + r.persianTerritories, 0) / results.length).toFixed(2),
            successionCrises: results.filter(r => r.victoryType === 'Succession Crisis').length
        };
    }

    analyzeGangsterStats(results) {
        const nypd_wins = results.filter(r => r.winner === 'NYPD');
        const corruptPolice = results.filter(r => r.nypd_corruption > 5);
        
        return {
            nypdWinRate: ((nypd_wins.length / results.length) * 100).toFixed(2) + '%',
            averageCorruption: (results.reduce((sum, r) => sum + r.nypd_corruption, 0) / results.length).toFixed(2),
            averageTrust: (results.reduce((sum, r) => sum + r.nypd_trust, 0) / results.length).toFixed(2),
            corruptPoliceGames: ((corruptPolice.length / results.length) * 100).toFixed(2) + '%',
            averageTotalTerritories: (results.reduce((sum, r) => sum + r.total_territories, 0) / results.length).toFixed(2)
        };
    }

    analyzeLAGangStats(results) {
        const lapd_wins = results.filter(r => r.winner === 'LAPD');
        const highViolence = results.filter(r => r.total_heat > 15);
        
        return {
            lapdWinRate: ((lapd_wins.length / results.length) * 100).toFixed(2) + '%',
            averageRespect: (results.reduce((sum, r) => sum + r.total_respect, 0) / results.length).toFixed(2),
            averageHeat: (results.reduce((sum, r) => sum + r.total_heat, 0) / results.length).toFixed(2),
            highViolenceGames: ((highViolence.length / results.length) * 100).toFixed(2) + '%',
            lapdParticipation: ((results.filter(r => r.lapd_active).length / results.length) * 100).toFixed(2) + '%'
        };
    }

    // Balance detection
    detectBalanceIssues(analysis) {
        const issues = [];
        const winnerDist = analysis.winnerDistribution;
        
        // Check for dominant factions (>60% win rate)
        Object.keys(winnerDist).forEach(winner => {
            const winRate = parseFloat(winnerDist[winner].percentage);
            if (winRate > 60) {
                issues.push(`${winner} has a very high win rate (${winRate}%) - possible balance issue`);
            }
            if (winRate < 10 && analysis.totalGames > 50) {
                issues.push(`${winner} has a very low win rate (${winRate}%) - possible underpowered`);
            }
        });

        // Check average game length
        const avgLength = parseFloat(analysis.averageGameLength);
        if (avgLength < 10) {
            issues.push(`Games are very short (${avgLength} turns average) - possibly too decisive`);
        }
        if (avgLength > 35) {
            issues.push(`Games are very long (${avgLength} turns average) - possibly too drawn out`);
        }

        // Game-specific balance checks
        if (analysis.gameSpecificStats.frenchWinRate) {
            const frenchWinRate = parseFloat(analysis.gameSpecificStats.frenchWinRate);
            if (frenchWinRate > 70) {
                issues.push('France is too powerful - coalition needs strengthening');
            }
            if (frenchWinRate < 30) {
                issues.push('France is too weak - needs buffs or coalition nerfs');
            }
        }

        if (analysis.gameSpecificStats.alexanderSurvivalRate) {
            const survivalRate = parseFloat(analysis.gameSpecificStats.alexanderSurvivalRate);
            if (survivalRate < 30) {
                issues.push('Alexander dies too frequently - mortality rate too high');
            }
        }

        return issues;
    }

    // Main CLI interface
    static main() {
        const args = process.argv.slice(2);
        const simulator = new GameSimulator();

        if (args.length === 0) {
            console.log(`
Board Game Simulator Usage:
node simulator.js <game-type> [iterations] [players] [options]

Game Types:
- napoleonic    : Napoleonic Wars
- alexander     : Alexander the Great
- gangsters     : Gangsters (Prohibition Era)
- la-gang-wars  : LA Gang Wars

Options:
- --analyze     : Show detailed analysis
- --export-csv  : Export results to CSV
- --detect-balance : Check for balance issues

Examples:
node simulator.js napoleonic 100
node simulator.js alexander 50 4 --analyze
node simulator.js gangsters 200 5 --export-csv --detect-balance
node simulator.js la-gang-wars 75 --analyze --export-csv
            `);
            return;
        }

        const gameType = args[0];
        const iterations = parseInt(args[1]) || 100;
        const playerCount = args[2] && !args[2].startsWith('--') ? parseInt(args[2]) : null;
        
        const showAnalysis = args.includes('--analyze');
        const exportCSV = args.includes('--export-csv');
        const detectBalance = args.includes('--detect-balance');

        try {
            // Run simulations
            const results = simulator.runSimulations(gameType, iterations, playerCount);
            
            // Export CSV if requested
            if (exportCSV) {
                const timestamp = new Date().toISOString().slice(0, 19).replace(/:/g, '-');
                const filename = `${gameType}_simulation_${iterations}games_${timestamp}.csv`;
                simulator.exportToCSV(results, filename);
            }

            // Show analysis if requested
            if (showAnalysis || detectBalance) {
                console.log('\n=== SIMULATION ANALYSIS ===');
                const analysis = simulator.analyzeResults(results);
                
                console.log(`\nGame: ${results[0].game}`);
                console.log(`Total Games: ${analysis.totalGames}`);
                console.log(`Average Game Length: ${analysis.averageGameLength} turns`);
                
                console.log('\n--- Winner Distribution ---');
                Object.keys(analysis.winnerDistribution).forEach(winner => {
                    const stats = analysis.winnerDistribution[winner];
                    console.log(`${winner}: ${stats.count} wins (${stats.percentage}%)`);
                });

                console.log('\n--- Victory Type Distribution ---');
                Object.keys(analysis.victoryTypeDistribution).forEach(type => {
                    const stats = analysis.victoryTypeDistribution[type];
                    console.log(`${type}: ${stats.count} games (${stats.percentage}%)`);
                });

                console.log('\n--- Game-Specific Stats ---');
                Object.keys(analysis.gameSpecificStats).forEach(stat => {
                    console.log(`${stat}: ${analysis.gameSpecificStats[stat]}`);
                });

                if (detectBalance) {
                    console.log('\n--- Balance Issues ---');
                    const issues = simulator.detectBalanceIssues(analysis);
                    if (issues.length === 0) {
                        console.log('No major balance issues detected.');
                    } else {
                        issues.forEach(issue => console.log(`⚠️  ${issue}`));
                    }
                }
            } else {
                // Quick summary
                const winnerCounts = {};
                results.forEach(r => winnerCounts[r.winner] = (winnerCounts[r.winner] || 0) + 1);
                
                console.log('\n=== QUICK RESULTS ===');
                Object.keys(winnerCounts).forEach(winner => {
                    const percentage = ((winnerCounts[winner] / results.length) * 100).toFixed(1);
                    console.log(`${winner}: ${winnerCounts[winner]}/${results.length} (${percentage}%)`);
                });
            }

        } catch (error) {
            console.error(`Error: ${error.message}`);
            process.exit(1);
        }
    }
}

// Run if called directly
if (require.main === module) {
    GameSimulator.main();
}

module.exports = GameSimulator;