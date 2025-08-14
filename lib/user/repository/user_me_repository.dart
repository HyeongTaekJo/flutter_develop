import 'package:dio/dio.dart' hide Headers;
import 'package:erp/common/dio/dio.dart';
import 'package:erp/user/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/http.dart';
import '../../common/const/data.dart';

part 'user_me_repository.g.dart';

final userMeRepositoryProvider = Provider<UserMeRepository>(
        (ref) {
      final dio = ref.watch(dioProvider);

      return UserMeRepository(dio, baseUrl: 'http://$ip/user/me');
    }
);

// http://$ip/user/me
@RestApi()
abstract class UserMeRepository{
  factory UserMeRepository(Dio dio, {String baseUrl}) = _UserMeRepository;

  @GET('/')
  @Headers({
    'accessToken': 'true',
  })
  Future<UserModel> getMe();

  //
  // @GET('/basket')
  // @Headers({
  //   'accessToken': 'true',
  // })
  // Future<List<BasketItemModel>> getBasket();
  //
  //
  // @PATCH('/basket')
  // @Headers({
  //   'accessToken': 'true',
  // })
  // Future<List<BasketItemModel>> patchBasket({
  //   @Body() required PatchBasketBody body,
  // });

}