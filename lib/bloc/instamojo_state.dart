import 'package:equatable/equatable.dart';
import 'package:instamojo/models/models.dart';
import 'package:meta/meta.dart';

abstract class InstamojoState extends Equatable {
  const InstamojoState();

  @override
  List<Object?> get props => [];
}

class InstamojoEmpty extends InstamojoState {}

class InstamojoLoading extends InstamojoState {}

class InstamojoLoaded extends InstamojoState {
  final PaymentOptionModel? paymentOptionModel;
  final String? collectCardRequest;
  final String? collectUPIRequest;
  final String? getUPIStatus;
  final List<NetbankingOptionsChoice>? banks;
  final LoadType? loadType;

  const InstamojoLoaded(
      {this.paymentOptionModel,
      this.banks,
      @required this.loadType,
      this.collectUPIRequest,
      this.getUPIStatus,
      this.collectCardRequest})
      : assert(loadType != null);

  @override
  List<Object?> get props => [paymentOptionModel];
}

class InstamojoError extends InstamojoState {}

enum LoadType {
  PaymentModel,
  CollectCardPayment,
  SearchBank,
  CollectUPIPayment,
  GetUPIStatus
}
