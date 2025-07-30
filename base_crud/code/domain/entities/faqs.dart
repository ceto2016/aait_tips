import '../base_domain_imports.dart';

class FaqEntity extends BaseEntity {
  final String question;
  final String answer;

  const FaqEntity({
    required super.id,
    required this.question,
    required this.answer,
  });

  @override
  FaqEntity copyWith({int? id, String? question, String? answer}) => FaqEntity(
    id: id ?? this.id,
    question: question ?? this.question,
    answer: answer ?? this.answer,
  );

  factory FaqEntity.fromJson(Map<String, dynamic> json) => FaqEntity(
    id: json["id"],
    question: json["question"],
    answer: json["answer"],
  );

  @override
  Map<String, dynamic> toJson() => {
    "id": id,
    "question": question,
    "answer": answer,
  };
}
