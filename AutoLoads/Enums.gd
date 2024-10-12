extends Node

enum ManaType {KNOT, TEETH, GUT}
enum DeckType {DECK, DISCARD}
enum PlayerState {SITTING_NEUTRAL, MOVING_PIECE, SPENDING_MANA}

var CardNameToCardResource: Dictionary = {
	"Spectral Steed": preload("res://Cards/Ability_Cards/Spells/SpectralSteed/SpectralSteed.tres"),
	"Jaska's Vigor": preload("res://Cards/Ability_Cards/Spells/Jaska_Vigor/Jaska_Vigor.tres")
}
