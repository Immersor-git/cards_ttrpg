extends Node

enum ManaType {KNOT, TEETH, GUT}
enum DeckType {DECK, DISCARD}
enum PlayerState {SITTING_NEUTRAL, OBSERVING_BOARD, MOVING_PIECE, SPENDING_MANA}

var CardNameToCardResource: Dictionary = {
	"Spectral Steed": preload("res://Cards/Ability_Cards/Spells/SpectralSteed/SpectralSteed.tres"),
	"Jaska's Vigor": preload("res://Cards/Ability_Cards/Spells/Jaska_Vigor/Jaska_Vigor.tres"),
	"Inkbird's Opal": preload("res://Cards/Ability_Cards/Spells/Inkbird_Opal/Inkbird_Opal.tres"),
	"Morning Star": preload("res://Cards/Ability_Cards/Weapons/MorningStar/MorningStar.tres"),
	"Nevik's Mending": preload("res://Cards/Ability_Cards/Spells/Nevik_Mending/NeviksMending.tres"),
	"Broadsword": preload("res://Cards/Ability_Cards/Weapons/Broadsword/Broadsword.tres"),
	"Halberd": preload("res://Cards/Ability_Cards/Weapons/Halberd/Halberd.tres")
}
