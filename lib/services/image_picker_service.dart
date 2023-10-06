import 'package:image_picker/image_picker.dart';

abstract class ImagePickerService {
  Future<XFile?> pickImage({required ImageSource source});
}

class ImagePickerServiceImpl implements ImagePickerService {
  @override
  Future<XFile?> pickImage({required ImageSource source}) =>
      ImagePicker().pickImage(source: source);
}
