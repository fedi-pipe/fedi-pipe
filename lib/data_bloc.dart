import 'package:flutter_bloc/flutter_bloc.dart';
import 'data_repository.dart';

abstract class DataEvent {}
class FetchData extends DataEvent {}

abstract class DataState {}
class DataInitial extends DataState {}
class DataLoading extends DataState {}
class DataLoaded extends DataState {
  final String data;
  DataLoaded(this.data);
}
class DataError extends DataState {
  final String message;
  DataError(this.message);
}

class DataBloc extends Bloc<DataEvent, DataState> {
  final DataRepository dataRepository;

  DataBloc({required this.dataRepository}) : super(DataInitial()) {
    on<FetchData>((event, emit) async {
      emit(DataLoading());
      try {
        final data = await dataRepository.fetchData();
        emit(DataLoaded(data));
      } catch (e) {
        emit(DataError(e.toString()));
      }
    });
  }
}
