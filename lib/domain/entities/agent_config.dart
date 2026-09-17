/// Domain entity representing an AI agent's configuration.
///
/// Each agent has a unique [id], a human-readable [name],
/// a [systemPrompt] that guides its behavior, and tunable
/// generation parameters like [temperature] and [maxTokens].
class AgentConfig {
  /// A sensible default configuration for quick-start scenarios.
  static const defaultConfig = AgentConfig(
    id: 'default',
    name: 'Default Agent',
    description: 'Built-in default agent configuration',
    systemPrompt: 'You are a helpful assistant.',
    modelId: 'default',
    temperature: 0.7,
    maxTokens: 2048,
  );

  const AgentConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.systemPrompt,
    this.modelId = 'default',
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.isDefault = false,
    this.isActive = true,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String systemPrompt;
  final String modelId;
  final double temperature;
  final int maxTokens;
  final bool isDefault;
  final bool isActive;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Creates a copy of this entity with optionally overridden fields.
  AgentConfig copyWith({
    String? id,
    String? name,
    String? description,
    String? systemPrompt,
    String? modelId,
    double? temperature,
    int? maxTokens,
    bool? isDefault,
    bool? isActive,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgentConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      systemPrompt: systemPrompt ?? this.systemPrompt,
      modelId: modelId ?? this.modelId,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentConfig && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
