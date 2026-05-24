import 'package:sakhi_ai/models/govt_scheme.dart';

/// Shown when backend/DB is unreachable (offline fallback).
const List<GovtScheme> kDemoSchemes = [
  GovtScheme(
    id: 'pm-kisan',
    name: 'PM-KISAN',
    summary: '₹6,000/year direct income support for farmer families.',
    state: 'All India',
    eligibility: 'Small & marginal farmers with land records',
  ),
  GovtScheme(
    id: 'pmfby',
    name: 'PM Fasal Bima Yojana',
    summary: 'Crop insurance at low premium with government subsidy.',
    state: 'All India',
    eligibility: 'Farmers growing notified crops',
  ),
  GovtScheme(
    id: 'kcc',
    name: 'Kisan Credit Card',
    summary: 'Easy credit for farming needs at subsidized interest.',
    state: 'All India',
    eligibility: 'Farmers, tenant farmers, SHGs',
  ),
];
