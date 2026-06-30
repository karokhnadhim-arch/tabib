import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:provider/provider.dart';



import '../../../core/auth/admin_permissions.dart';

import '../../../core/theme/app_theme.dart';

import '../../../core/utils/staff_auth_identifiers.dart';

import '../../../core/widgets/responsive_scaffold.dart';

import '../../../l10n/app_localizations.dart';

import '../../../models/service_provider_type.dart';

import '../../../presentation/widgets/admin_guard.dart';

import '../../../presentation/widgets/staff_account_login_fields.dart';

import '../../../services/auth_service.dart';

import '../../../services/clinic_data_service.dart';

import '../../../utils/localization_utils.dart';

import '../../../utils/provider_labels.dart';

import '../../../widgets/auth/auth_text_field.dart';



class CreateDoctorScreen extends StatefulWidget {

  const CreateDoctorScreen({super.key});



  @override

  State<CreateDoctorScreen> createState() => _CreateDoctorScreenState();

}



class _CreateDoctorScreenState extends State<CreateDoctorScreen> {

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();

  final _emailController = TextEditingController();

  final _phoneController = TextEditingController();

  final _passwordController = TextEditingController();



  StaffLoginMethod _loginMethod = StaffLoginMethod.phone;

  ServiceProviderAccountType _accountType = ServiceProviderAccountType.doctor;

  BusinessCategory? _businessCategory;

  String? _specialtyId;

  String? _clinicId;

  bool _loading = false;

  String? _error;



  @override

  void dispose() {

    _nameController.dispose();

    _emailController.dispose();

    _phoneController.dispose();

    _passwordController.dispose();

    super.dispose();

  }



  String _resolvedSpecialtyId(ClinicDataService data) {

    if (_accountType.isBusiness) {

      return _businessCategory?.defaultSpecialtyId ?? 'healthcare_services';

    }

    return _specialtyId ??

        (data.specialties.isNotEmpty ? data.specialties.first.id : '');

  }



  Future<void> _submit() async {

    if (!_formKey.currentState!.validate()) return;

    if (_clinicId == null) {

      setState(() => _error = AppLocalizations.of(context).fieldRequired);

      return;

    }

    if (_accountType.isDoctor && _specialtyId == null) {

      setState(() => _error = AppLocalizations.of(context).fieldRequired);

      return;

    }

    if (_accountType.isBusiness && _businessCategory == null) {

      setState(() => _error = AppLocalizations.of(context).fieldRequired);

      return;

    }



    setState(() {

      _loading = true;

      _error = null;

    });



    final auth = context.read<AuthService>();

    final l10n = AppLocalizations.of(context);

    final err = await auth.createDoctorAccount(

      name: _nameController.text.trim(),

      loginMethod: _loginMethod,

      email: _emailController.text.trim(),

      phone: _phoneController.text.trim(),

      password: _passwordController.text,

      specialtyId: _resolvedSpecialtyId(context.read<ClinicDataService>()),

      clinicId: _clinicId!,

      accountType: _accountType,

      businessCategory:

          _accountType.isBusiness ? _businessCategory : null,

    );



    if (!mounted) return;

    setState(() => _loading = false);



    if (err == null) {

      ScaffoldMessenger.of(context).showSnackBar(

        SnackBar(content: Text(l10n.accountCreated)),

      );

      context.pop();

    } else {

      setState(() {

        _error = err == 'email_in_use'

            ? l10n.emailInUse

            : err == 'phone_in_use'

                ? l10n.phoneInUse

                : err == 'weak_password'

                    ? l10n.weakPassword

                    : err == 'invalid_phone'

                        ? l10n.invalidPhone

                        : l10n.errorGeneric;

      });

    }

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);

    final auth = context.watch<AuthService>();

    if (!AdminPermissions.canCreateDoctors(auth)) {

      return const SizedBox.shrink();

    }

    final data = context.watch<ClinicDataService>();



    _specialtyId ??=

        data.specialties.isNotEmpty ? data.specialties.first.id : null;

    _clinicId ??= data.clinics.isNotEmpty ? data.clinics.first.id : null;

    _businessCategory ??= BusinessCategory.clinic;



    return AdminGuard(

      child: Scaffold(

        appBar: AppBar(

          title: Text(ProviderLabels.createAccountTitle(l10n, _accountType)),

          backgroundColor: AppTheme.primaryDark,

        ),

        body: SingleChildScrollView(

          padding: const EdgeInsets.all(20),

          child: Form(

            key: _formKey,

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [

                Text(

                  l10n.accountType,

                  style: Theme.of(context).textTheme.titleSmall,

                ),

                const SizedBox(height: 8),

                ResponsiveSegmentedButton<ServiceProviderAccountType>(

                  segments: [

                    ButtonSegment(

                      value: ServiceProviderAccountType.doctor,

                      label: Text(l10n.accountTypeDoctor),

                    ),

                    ButtonSegment(

                      value: ServiceProviderAccountType.business,

                      label: Text(l10n.accountTypeBusiness),

                    ),

                  ],

                  selected: {_accountType},

                  onSelectionChanged: (value) => setState(() {

                    _accountType = value.first;

                  }),

                ),

                const SizedBox(height: 20),

                AuthTextField(

                  controller: _nameController,

                  label: _accountType.isBusiness
                      ? l10n.businessName
                      : l10n.doctorName,

                  prefixIcon: Icons.person_outline,

                  validator: (v) => v == null || v.trim().length < 2

                      ? l10n.invalidName

                      : null,

                ),

                const SizedBox(height: 20),

                StaffAccountLoginFields(

                  loginMethod: _loginMethod,

                  onLoginMethodChanged: (method) =>

                      setState(() => _loginMethod = method),

                  emailController: _emailController,

                  phoneController: _phoneController,

                  passwordController: _passwordController,

                ),

                const SizedBox(height: 16),

                if (_accountType.isBusiness)

                  DropdownButtonFormField<BusinessCategory>(

                    value: _businessCategory,

                    decoration: InputDecoration(

                      labelText: l10n.selectBusinessCategory,

                      prefixIcon: const Icon(Icons.storefront_outlined),

                    ),

                    items: BusinessCategory.values

                        .map(

                          (category) => DropdownMenuItem(

                            value: category,

                            child: Text(

                              ProviderLabels.businessCategoryLabel(

                                l10n,

                                category,

                              ),

                            ),

                          ),

                        )

                        .toList(),

                    onChanged: (v) => setState(() => _businessCategory = v),

                  )

                else

                  DropdownButtonFormField<String>(

                    value: _specialtyId,

                    decoration: InputDecoration(

                      labelText: l10n.selectSpecialty,

                      prefixIcon: const Icon(Icons.category_outlined),

                    ),

                    items: data.specialties

                        .map(

                          (s) => DropdownMenuItem(

                            value: s.id,

                            child: Text(s.name.localized(context)),

                          ),

                        )

                        .toList(),

                    onChanged: (v) => setState(() => _specialtyId = v),

                  ),

                const SizedBox(height: 16),

                DropdownButtonFormField<String>(

                  value: _clinicId,

                  decoration: InputDecoration(

                    labelText: l10n.selectClinic,

                    prefixIcon: const Icon(Icons.local_hospital_outlined),

                  ),

                  items: data.clinics

                      .map(

                        (c) => DropdownMenuItem(

                          value: c.id,

                          child: Text(c.name.localized(context)),

                        ),

                      )

                      .toList(),

                  onChanged: (v) => setState(() => _clinicId = v),

                ),

                if (_error != null) ...[

                  const SizedBox(height: 12),

                  Text(

                    _error!,

                    style: TextStyle(color: Colors.red.shade700),

                    textAlign: TextAlign.center,

                  ),

                ],

                const SizedBox(height: 24),

                FilledButton(

                  onPressed: _loading ? null : _submit,

                  style: FilledButton.styleFrom(

                    backgroundColor: AppTheme.primaryDark,

                    minimumSize: const Size.fromHeight(52),

                  ),

                  child: _loading

                      ? const SizedBox(

                          height: 22,

                          width: 22,

                          child: CircularProgressIndicator(

                            strokeWidth: 2,

                            color: Colors.white,

                          ),

                        )

                      : Text(

                          ProviderLabels.createAccountTitle(l10n, _accountType),

                        ),

                ),

              ],

            ),

          ),

        ),

      ),

    );

  }

}


