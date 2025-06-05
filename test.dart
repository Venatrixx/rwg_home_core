import 'package:home_info_point_client/home_info_point_client.dart';

void main() async {
  final client = HipClient(HipConfig(schoolCode: 'rwg-waren', username: '281628', password: 'MRUVFE'));

  await client.fetch();

  print(await client.asJsonString());
}
