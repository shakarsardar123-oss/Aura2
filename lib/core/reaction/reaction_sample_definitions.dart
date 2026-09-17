/// Sample reaction definitions for development and testing.
///
/// These 8 reactions cover each trigger type and demonstrate the
/// full range of presentation types. They are registered in the
/// catalog at startup via [reactionCatalogProvider].
///
/// In a future step, these will be replaced / augmented by a
/// persistent data source. For Step 2, they serve as the test
/// population for the selector, engine, and history.
library;

import 'reaction_model.dart';
import 'reaction_type.dart';
import 'reaction_trigger.dart';
import 'reaction_constants.dart';
import 'reaction_visual_style.dart';

/// The canonical sample reactions for Step 2 development.
final List<Reaction> sampleReactions = [
  // ── Voice state reactions ──
  Reaction(
    id: 'listening_ear',
    type: const EmojiReactionType('👂'),
    trigger: ReactionTrigger.voiceState,
    priority: 0.7,
    weight: 1.0,
    cooldown: const Duration(seconds: 15),
    l10nKey: 'reaction_listening',
    category: ReactionCategories.voice,
    tags: [ReactionTags.feedback],
    requiredVoiceStates: ['listening'],
    payload: {'emoji': '👂'},
    visualStyle: ReactionVisualStyle.emoji,
  ),
  Reaction(
    id: 'speaking_mouth',
    type: const EmojiReactionType('💬'),
    trigger: ReactionTrigger.voiceState,
    priority: 0.7,
    weight: 1.0,
    cooldown: const Duration(seconds: 15),
    l10nKey: 'reaction_speaking',
    category: ReactionCategories.voice,
    tags: [ReactionTags.feedback],
    requiredVoiceStates: ['speaking'],
    payload: {'emoji': '💬'},
    visualStyle: ReactionVisualStyle.emoji,
  ),

  // ── Agent state reactions ──
  Reaction(
    id: 'thinking_gear',
    type: const EmojiReactionType('⚙️'),
    trigger: ReactionTrigger.agentState,
    priority: 0.6,
    weight: 1.0,
    cooldown: const Duration(seconds: 20),
    l10nKey: 'reaction_processing',
    category: ReactionCategories.agent,
    tags: [ReactionTags.progress],
    requiredAgentStates: ['understanding', 'planning', 'executing', 'validating'],
    payload: {'emoji': '⚙️'},
    visualStyle: ReactionVisualStyle.emoji,
  ),
  Reaction(
    id: 'complete_check',
    type: const TextReactionType(),
    trigger: ReactionTrigger.agentState,
    priority: 0.8,
    weight: 1.2,
    cooldown: const Duration(seconds: 30),
    l10nKey: 'reaction_completed',
    urgency: ReactionUrgency.normal,
    tone: ReactionTone.positive,
    category: ReactionCategories.agent,
    tags: [ReactionTags.confirmation],
    requiredAgentStates: ['completed'],
    payload: {'textKey': 'reaction_completed'},
    visualStyle: ReactionVisualStyle.asciiArt,
  ),

  // ── Error event reactions ──
  Reaction(
    id: 'error_alert',
    type: const EmojiReactionType('⚠️'),
    trigger: ReactionTrigger.errorEvent,
    priority: 0.9,
    weight: 1.5,
    cooldown: const Duration(seconds: 10),
    l10nKey: 'reaction_error',
    urgency: ReactionUrgency.high,
    tone: ReactionTone.soothing,
    category: ReactionCategories.error,
    tags: [ReactionTags.error],
    payload: {'emoji': '⚠️'},
    visualStyle: ReactionVisualStyle.emoji,
  ),

  // ── Tool execution reactions ──
  Reaction(
    id: 'tool_wrench',
    type: const EmojiReactionType('🔧'),
    trigger: ReactionTrigger.toolExecution,
    priority: 0.5,
    weight: 1.0,
    cooldown: const Duration(seconds: 20),
    l10nKey: 'reaction_tool_running',
    category: ReactionCategories.tool,
    tags: [ReactionTags.progress],
    payload: {'emoji': '🔧'},
    visualStyle: ReactionVisualStyle.emoji,
  ),

  // ── Wake event reactions ──
  Reaction(
    id: 'wake_sparkle',
    type: const EmojiReactionType('✨'),
    trigger: ReactionTrigger.wakeEvent,
    priority: 0.9,
    weight: 2.0,
    cooldown: const Duration(seconds: 60),
    l10nKey: 'reaction_wake',
    tone: ReactionTone.positive,
    category: ReactionCategories.personality,
    tags: [ReactionTags.feedback, ReactionTags.personality],
    payload: {'emoji': '✨'},
    visualStyle: ReactionVisualStyle.emoji,
  ),

  // ── Idle timeout reactions ──
  Reaction(
    id: 'idle_hint_bulb',
    type: const EmojiReactionType('💡'),
    trigger: ReactionTrigger.idleTimeout,
    priority: 0.3,
    weight: 0.5,
    cooldown: const Duration(minutes: 5),
    l10nKey: 'reaction_idle_hint',
    tone: ReactionTone.neutral,
    category: ReactionCategories.idle,
    tags: [ReactionTags.idleHint],
    payload: {'emoji': '💡'},
    visualStyle: ReactionVisualStyle.emoji,
  ),
];

/// Step 4 additional sample reactions demonstrating visual style variety.
/// These can be registered alongside the Step 2 samples for testing
/// style rotation and variation.
final List<Reaction> step4SampleReactions = [
  // ── Pixel-art style reactions ──
  Reaction(
    id: 'pixel_listening',
    type: const EmojiReactionType('🎵'),
    trigger: ReactionTrigger.voiceState,
    priority: 0.5,
    weight: 0.8,
    cooldown: const Duration(seconds: 20),
    l10nKey: 'reaction_pixel_listening',
    category: ReactionCategories.voice,
    tags: [ReactionTags.feedback, 'pixel'],
    requiredVoiceStates: ['listening'],
    visualStyle: ReactionVisualStyle.pixelArt,
    payload: {'emoji': '🎵', 'visualStyle': 'pixel_art'},
  ),
  Reaction(
    id: 'pixel_complete',
    type: const TextReactionType(),
    trigger: ReactionTrigger.agentState,
    priority: 0.6,
    weight: 0.9,
    cooldown: const Duration(seconds: 25),
    l10nKey: 'reaction_pixel_complete',
    tone: ReactionTone.positive,
    category: ReactionCategories.agent,
    tags: [ReactionTags.confirmation, 'pixel'],
    requiredAgentStates: ['completed'],
    visualStyle: ReactionVisualStyle.pixelArt,
    payload: {'textKey': 'reaction_pixel_complete', 'visualStyle': 'pixel_art'},
  ),

  // ── ASCII-art style reactions ──
  Reaction(
    id: 'ascii_processing',
    type: const TerminalReactionType(),
    trigger: ReactionTrigger.agentState,
    priority: 0.5,
    weight: 0.7,
    cooldown: const Duration(seconds: 20),
    l10nKey: 'reaction_ascii_processing',
    tone: ReactionTone.neutral,
    category: ReactionCategories.agent,
    tags: [ReactionTags.progress, 'ascii'],
    requiredAgentStates: ['executing', 'planning'],
    visualStyle: ReactionVisualStyle.asciiArt,
    payload: {'textKey': 'reaction_ascii_processing', 'visualStyle': 'ascii_art'},
  ),

  // ── Code style reactions ──
  Reaction(
    id: 'code_tool_exec',
    type: const CodeReactionType('dart'),
    trigger: ReactionTrigger.toolExecution,
    priority: 0.4,
    weight: 0.6,
    cooldown: const Duration(seconds: 25),
    l10nKey: 'reaction_code_tool',
    tone: ReactionTone.technical,
    category: ReactionCategories.tool,
    tags: [ReactionTags.progress, 'code'],
    visualStyle: ReactionVisualStyle.code,
    payload: {'language': 'dart', 'visualStyle': 'code'},
  ),

  // ── Meme style reactions ──
  Reaction(
    id: 'meme_wake',
    type: const HumorReactionType(),
    trigger: ReactionTrigger.wakeEvent,
    priority: 0.7,
    weight: 1.5,
    cooldown: const Duration(seconds: 60),
    l10nKey: 'reaction_meme_wake',
    tone: ReactionTone.humorous,
    category: ReactionCategories.personality,
    tags: [ReactionTags.feedback, ReactionTags.personality, 'meme'],
    visualStyle: ReactionVisualStyle.meme,
    payload: {'textKey': 'reaction_meme_wake', 'visualStyle': 'meme'},
  ),

  // ── Idle reactions with different styles for variation ──
  Reaction(
    id: 'idle_ascii_hint',
    type: const TextReactionType(),
    trigger: ReactionTrigger.idleTimeout,
    priority: 0.3,
    weight: 0.4,
    cooldown: const Duration(minutes: 5),
    l10nKey: 'reaction_idle_ascii_hint',
    tone: ReactionTone.neutral,
    category: ReactionCategories.idle,
    tags: [ReactionTags.idleHint, 'ascii'],
    visualStyle: ReactionVisualStyle.asciiArt,
    payload: {'textKey': 'reaction_idle_ascii_hint', 'visualStyle': 'ascii_art'},
  ),
];
