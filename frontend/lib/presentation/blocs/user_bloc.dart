import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../core/utils/usecase.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class GetUserEvent extends UserEvent {
  const GetUserEvent();
}

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded(this.user);

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);

  @override
  List<Object> get props => [message];
}

class UserBloc extends Bloc<UserEvent, UserState> {
  final GetCurrentUser getCurrentUser;

  UserBloc({
    required this.getCurrentUser,
  }) : super(UserInitial()) {
    on<GetUserEvent>(_onGetUser);
  }

  void _onGetUser(GetUserEvent event, Emitter<UserState> emit) async {
    emit(UserLoading());
    
    final result = await getCurrentUser(NoParams());
    
    result.fold(
      (failure) => emit(UserError('Ошибка загрузки пользователя')),
      (user) => emit(UserLoaded(user)),
    );
  }
}
