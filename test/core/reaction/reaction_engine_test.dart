import 'package:flutter_test/flutter_test.dart';
import 'package:aura_assistant/core/reaction/reaction.dart';
import 'package:aura_assistant/core/errors/result.dart';

void main() {
  group('ReactionEngine', () {
    late ReactionCatalog catalog;
    late FrozenClock clock;
    late ReactionHistory history;
    late StyleAwareSelector selector;
    late DeterministicRandomSource random;
    late ReactionEngine engine;
    final baseTime = DateTime(2026, 1, 1, 12, 0, 0);

    setUp(() {
      catalog = ReactionCatalog();
      clock = FrozenClock(baseTime);
      history = ReactionHistory(clock: clock);
      selector = StyleAwareSelector(baseSelector: const ReactionSelector());
      random = DeterministicRandomSource([0.0]); // always pick first
      engine = ReactionEngine(
        catalog: catalog,
        selector: selector,
        history: history,
        randomSource: random,
        clock: clock,
      );
    });

    tearDown(() {
      engine.dispose();
    });

    test('initial state is idle with no reaction', () {
      expect(engine.state.status, ReactionEngineStatus.idle);
      expect(engine.state.currentReaction, isNull);
      expect(engine.state.totalSelections, 0);
    });

    test('evaluate returns success for matching reaction', () {
      catalog.register(Reaction(
        id: 'test_reaction',
        type: const EmojiReactionType('🧪'),
        trigger: ReactionTrigger.voiceState,
        priority: 0.7,
        requiredVoiceStates: ['listening'],
      ));

      final ctx = ReactionContext(
        trigger: ReactionTrigger.voiceState,
        voiceState: 'listening',
        timestamp: baseTime,
      );

      final result = engine.evaluate(ctx);

      expect(result.isSuccess, isTrue);
      result.when(
        success: (reaction) => expect(reaction.id, 'test_reaction'),
        failure: (_) => fail('Expected success'),
      );
    });

    test('evaluate updates state on success', () {
      catalog.register(Reaction(
        id: 'state_test',
        type: const EmojiReactionType('📊'),
        trigger: ReactionTrigger.agentState,
        priority: 0.5,
      ));

      final ctx = ReactionContext(
        trigger: ReactionTrigger.agentState,
        timestamp: baseTime,
      );

      engine.evaluate(ctx);

      expect(engine.state.lastReactionId, 'state_test');
      expect(engine.state.totalSelections, 1);
      expect(engine.state.lastSelectedAt, baseTime);
    });

    test('evaluate records in history', () {
      catalog.register(Reaction(
        id: 'hist_test',
        type: const EmojiReactionType('📝'),
        trigger: ReactionTrigger.voiceState,
        priority: 0.5,
      ));

      final ctx = ReactionContext(
        trigger: ReactionTrigger.voiceState,
        timestamp: baseTime,
      );

      engine.evaluate(ctx);

      expect(history.length, 1);
      expect(history.entries.last.reactionId, 'hist_test');
    });

    test('evaluate returns failure when no eligible reaction', () {
      catalog.register(Reaction(
        id: 'wrong_trigger',
        type: const EmojiReactionType('❌'),
        trigger: ReactionTrigger.errorEvent,
        priority: 0.5,
      ));

      final ctx = ReactionContext(
        trigger: ReactionTrigger.voiceState,
        timestamp: baseTime,
      );

      final result = engine.evaluate(ctx);

      expect(result.isFailure, isTrue);
      result.when(
        success: (_) => fail('Expected failure'),
        failure: (f) {
          expect(f.code, 'NO_ELIGIBLE_REACTION');
          expect(f.phase, ReactionPhase.selection);
        },
      );
    });

    test('clearReaction resets current reaction', () {
      catalog.register(Reaction(
        id: 'clearable',
        type: const EmojiReactionType('🧹'),
        trigger: ReactionTrigger.voiceState,
        priority: 0.5,
      ));

      final ctx = ReactionContext(
        trigger: ReactionTrigger.voiceState,
        timestamp: baseTime,
      );

      engine.evaluate(ctx);
      expect(engine.state.lastReactionId, 'clearable');

      engine.clearReaction();
      expect(engine.state.currentReaction, isNull);
      expect(engine.state.status, ReactionEngineStatus.idle);
    });

    test('reset clears state and history', () {
      catalog.register(Reaction(
        id: 'reset_test',
        type: const EmojiReactionType('🔄'),
        trigger: ReactionTrigger.voiceState,
        priority: 0.5,
      ));

      final ctx = ReactionContext(
        trigger: ReactionTrigger.voiceState,
        timestamp: baseTime,
      );

      engine.evaluate(ctx);
      expect(engine.state.totalSelections, 1);
      expect(history.length, 1);

      engine.reset();
      expect(engine.state.totalSelections, 0);
      expect(engine.state.lastReactionId, isNull);
      expect(history.isEmpty, isTrue);
    });

    test('multiple evaluations increment totalSelections', () {
      catalog.register(Reaction(
        id: 'multi',
        type: const EmojiReactionType('🔢'),
        trigger: ReactionTrigger.agentState,
        priority: 0.5,
        cooldown: Duration.zero, // no cooldown for this test
      ));

      final ctx = ReactionContext(
        trigger: ReactionTrigger.agentState,
        timestamp: baseTime,
      );

      engine.evaluate(ctx);
      // Step 5: Must complete the reaction before the next evaluate.
      engine.completeReaction();
      clock.advance(const Duration(seconds: 1));
      // Create new context with updated timestamp
      final ctx2 = ReactionContext(
        trigger: ReactionTrigger.agentState,
        timestamp: clock.now(),
      );
      engine.evaluate(ctx2);
      engine.completeReaction();
      clock.advance(const Duration(seconds: 1));
      final ctx3 = ReactionContext(
        trigger: ReactionTrigger.agentState,
        timestamp: clock.now(),
      );
      engine.evaluate(ctx3);
      engine.completeReaction();

      expect(engine.state.totalSelections, 3);
    });

    test('catalog and history are accessible', () {
      expect(engine.catalog, same(catalog));
      expect(engine.history, same(history));
    });
  });

  group('ReactionState', () {
    test('initial state is idle', () {
      const state = ReactionState.initial;
      expect(state.status, ReactionEngineStatus.idle);
      expect(state.currentReaction, isNull);
      expect(state.totalSelections, 0);
    });

    test('default constructor is same as initial', () {
      const defaultState = ReactionState();
      expect(defaultState.status, ReactionEngineStatus.idle);
      expect(defaultState.totalSelections, 0);
    });

    test('hasActiveReaction', () {
      const noReaction = ReactionState();
      expect(noReaction.hasActiveReaction, isFalse);

      // Step 5: hasActiveReaction requires status == reacting
      // (not just having a currentReaction).
      final withReactionButIdle = ReactionState(
        currentReaction: Reaction(
          id: 'active',
          type: const EmojiReactionType('🟢'),
          trigger: ReactionTrigger.voiceState,
          priority: 0.5,
        ),
      );
      expect(withReactionButIdle.hasActiveReaction, isFalse);

      final withReactionAndReacting = ReactionState(
        status: ReactionEngineStatus.reacting,
        currentReaction: Reaction(
          id: 'active',
          type: const EmojiReactionType('🟢'),
          trigger: ReactionTrigger.voiceState,
          priority: 0.5,
        ),
      );
      expect(withReactionAndReacting.hasActiveReaction, isTrue);
    });

    test('copyWith', () {
      const base = ReactionState();
      final updated = base.copyWith(
        status: ReactionEngineStatus.evaluating,
        totalSelections: 5,
      );

      expect(updated.status, ReactionEngineStatus.evaluating);
      expect(updated.totalSelections, 5);
      expect(updated.currentReaction, isNull); // preserved
    });

    test('toString includes useful info', () {
      final state = ReactionState(
        status: ReactionEngineStatus.reacting,
        totalSelections: 3,
      );
      final str = state.toString();
      expect(str, contains('reacting'));
      expect(str, contains('3'));
    });
  });

  group('ReactionEngineStatus', () {
    test('isActive for evaluating and reacting', () {
      expect(ReactionEngineStatus.evaluating.isActive, isTrue);
      expect(ReactionEngineStatus.reacting.isActive, isTrue);
    });

    test('is not active for idle and error', () {
      expect(ReactionEngineStatus.idle.isActive, isFalse);
      expect(ReactionEngineStatus.error.isActive, isFalse);
    });
  });
}
