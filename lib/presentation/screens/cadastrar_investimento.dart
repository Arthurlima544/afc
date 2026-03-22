import 'package:clerk_flutter/clerk_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entity/investment_entity.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/investment/investment_cubit.dart';
import '../widgets/design_system.dart';

class CadastrarInvestimento extends StatefulWidget {
  const CadastrarInvestimento({super.key, this.initialInvestment});

  final InvestmentEntity? initialInvestment;

  @override
  State<CadastrarInvestimento> createState() => _CadastrarInvestimentoState();
}

class _CadastrarInvestimentoState extends State<CadastrarInvestimento> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _tickerController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _avgCostController = TextEditingController();
  final TextEditingController _currentPriceController = TextEditingController();

  String _selectedType = 'stock';

  String? _nameError;
  String? _quantityError;
  String? _avgCostError;
  String? _currentPriceError;

  static const List<String> _types = <String>[
    'stock',
    'fixed',
    'crypto',
    'other',
  ];

  static const List<String> _typeLabels = <String>[
    'Ação',
    'Renda Fixa',
    'Cripto',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialInvestment != null) {
      final InvestmentEntity inv = widget.initialInvestment!;
      _nameController.text = inv.name;
      _tickerController.text = inv.ticker ?? '';
      _quantityController.text = inv.quantity.toString();
      _avgCostController.text = inv.avgCost.toString();
      _currentPriceController.text = inv.currentPrice.toString();
      _selectedType = inv.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _tickerController.dispose();
    _quantityController.dispose();
    _avgCostController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError = _nameController.text.trim().isEmpty
          ? 'Informe o nome do investimento'
          : null;

      final double? qty = double.tryParse(
        _quantityController.text.replaceAll(',', '.'),
      );
      _quantityError = (qty == null || qty <= 0)
          ? 'Informe uma quantidade válida'
          : null;

      final double? avgCost = double.tryParse(
        _avgCostController.text.replaceAll(',', '.'),
      );
      _avgCostError = (avgCost == null || avgCost < 0)
          ? 'Informe um preço médio válido'
          : null;

      final double? price = double.tryParse(
        _currentPriceController.text.replaceAll(',', '.'),
      );
      _currentPriceError = (price == null || price < 0)
          ? 'Informe um preço atual válido'
          : null;
    });
    return _nameError == null &&
        _quantityError == null &&
        _avgCostError == null &&
        _currentPriceError == null;
  }

  @override
  Widget build(
    BuildContext context,
  ) => Scaffold(
    appBar: AppBar(leading: BackButton(onPressed: () => context.pop())),
    body: BlocListener<InvestmentCubit, InvestmentState>(
    listener: (BuildContext context, InvestmentState state) {
      state.whenOrNull(success: (_) => context.pop());
    },
    child: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.initialInvestment != null
                  ? 'Editar Investimento'
                  : 'Novo Investimento',
              style: AppTextStyles.heading,
            ),
            const Gap(20),
            AppTextField(
              controller: _nameController,
              hintText: 'Nome (ex: Petrobras)',
              onChanged: (_) => setState(() => _nameError = null),
            ),
            if (_nameError != null) ...<Widget>[
              const Gap(4),
              Text(
                _nameError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.expense),
              ),
            ],
            const Gap(16),
            AppTextField(
              controller: _tickerController,
              hintText: 'Ex: PETR4 (opcional)',
            ),
            const Gap(16),
            const Text('Tipo', style: AppTextStyles.bodyBold),
            const Gap(8),
            Row(
              children: <Widget>[
                for (int i = 0; i < _types.length; i++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: i < _types.length - 1 ? 8 : 0,
                      ),
                      child: _selectedType == _types[i]
                          ? PrimaryButton(
                              onPressed: () =>
                                  setState(() => _selectedType = _types[i]),
                              child: Text(
                                _typeLabels[i],
                                style: const TextStyle(fontSize: 11),
                              ),
                            )
                          : OutlineButton(
                              onPressed: () =>
                                  setState(() => _selectedType = _types[i]),
                              child: Text(
                                _typeLabels[i],
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                    ),
                  ),
              ],
            ),
            const Gap(16),
            AppTextField(
              controller: _quantityController,
              hintText: 'Quantidade',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              onChanged: (_) => setState(() => _quantityError = null),
            ),
            if (_quantityError != null) ...<Widget>[
              const Gap(4),
              Text(
                _quantityError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.expense),
              ),
            ],
            const Gap(16),
            AppTextField(
              controller: _avgCostController,
              hintText: 'Preço médio (ex: 28.50)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              onChanged: (_) => setState(() => _avgCostError = null),
            ),
            if (_avgCostError != null) ...<Widget>[
              const Gap(4),
              Text(
                _avgCostError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.expense),
              ),
            ],
            const Gap(16),
            AppTextField(
              controller: _currentPriceController,
              hintText: 'Preço atual (ex: 32.00)',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
              onChanged: (_) => setState(() => _currentPriceError = null),
            ),
            if (_currentPriceError != null) ...<Widget>[
              const Gap(4),
              Text(
                _currentPriceError!,
                style: AppTextStyles.caption.copyWith(color: AppColors.expense),
              ),
            ],
            const Gap(24),
            BlocBuilder<InvestmentCubit, InvestmentState>(
              builder: (BuildContext context, InvestmentState state) {
                final bool isLoading =
                    state.whenOrNull(loading: () => true) ?? false;
                return SizedBox(
                  width: double.infinity,
                  child: PrimaryButton(
                    onPressed: isLoading ? null : _save,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.onPrimary,
                            ),
                          )
                        : Text(
                            widget.initialInvestment != null
                                ? 'Salvar'
                                : 'Criar',
                          ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    ),
  ),
  );

  void _save() {
    if (!_validate()) {
      return;
    }

    final double quantity = double.parse(
      _quantityController.text.replaceAll(',', '.'),
    );
    final double avgCost = double.parse(
      _avgCostController.text.replaceAll(',', '.'),
    );
    final double currentPrice = double.parse(
      _currentPriceController.text.replaceAll(',', '.'),
    );
    final String? ticker = _tickerController.text.trim().isNotEmpty
        ? _tickerController.text.trim()
        : null;

    context.read<AuthBloc>().state.whenOrNull(
      signedIn: (ClerkAuthState authState) {
        final String userId = authState.user?.id ?? '';
        if (widget.initialInvestment != null) {
          context.read<InvestmentCubit>().update(
            widget.initialInvestment!.copyWith(
              name: _nameController.text.trim(),
              ticker: ticker,
              type: _selectedType,
              quantity: quantity,
              avgCost: avgCost,
              currentPrice: currentPrice,
            ),
          );
        } else {
          context.read<InvestmentCubit>().create(
            InvestmentEntity(
              uuid: const Uuid().v1(),
              userId: userId,
              name: _nameController.text.trim(),
              ticker: ticker,
              type: _selectedType,
              quantity: quantity,
              avgCost: avgCost,
              currentPrice: currentPrice,
            ),
          );
        }
      },
    );
  }
}
