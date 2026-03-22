part of 'template_cubit.dart';

@freezed
sealed class TemplateState with _$TemplateState {
  const factory TemplateState.initial() = _Initial;
  const factory TemplateState.loading() = _Loading;
  const factory TemplateState.listed(List<TemplateEntity> templates) = _Listed;
  const factory TemplateState.success(TemplateEntity template) = _Success;
  const factory TemplateState.error(String message) = _Error;
}
