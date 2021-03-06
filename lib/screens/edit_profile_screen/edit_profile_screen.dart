import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learnship/data/models/models.dart';
import 'package:learnship/data/repositories/repositories.dart';
import 'package:learnship/logic/bloc/profile/profile_bloc.dart';
import 'package:learnship/logic/cubit/edit_profile_cubit/edit_profile_cubit.dart';
import 'package:learnship/screens/widgets/widgets.dart';
import 'package:learnship/core/helper/image_helper.dart';

class EditProfileScreenArgs {
  final BuildContext context;

  EditProfileScreenArgs({@required this.context});
}

class EditProfileScreen extends StatelessWidget {
  static const String routeName = '/editProfileScreen';

  static Route route({@required EditProfileScreenArgs args}) {
    return MaterialPageRoute(
      settings: const RouteSettings(name: routeName),
      builder: (context) => BlocProvider<EditProfileCubit>(
        create: (_) => EditProfileCubit(
          userRepository: context.read<UserRepository>(),
          storageRepository: context.read<StorageRepository>(),
          profileBloc: args.context.read<ProfileBloc>(),
        ),
        child: EditProfileScreen(
            user: args.context.read<ProfileBloc>().state.user),
      ),
    );
  }

  final User user;

  EditProfileScreen({Key key, @required this.user}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
        ),
        body: BlocConsumer<EditProfileCubit, EditProfileState>(
          listener: (context, state) {
            if (state.status == EditProfileStatus.success) {
              Navigator.pop(context);
            } else if (state.status == EditProfileStatus.error) {
              showDialog(
                context: context,
                builder: (context) =>
                    ErrorDialog(content: state.failure.message),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  if (state.status == EditProfileStatus.submitting)
                    const LinearProgressIndicator(),
                  const SizedBox(height: 32.0),
                  GestureDetector(
                    onTap: () => _selectProfileImage(context),
                    child: UserProfileImage(
                      radius: 80.0,
                      profileImageUrl: user.profileImageUrl,
                      profileImage: state.profileImage,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            initialValue: user.username,
                            decoration: InputDecoration(hintText: 'Username'),
                            onChanged: (value) => context
                                .read<EditProfileCubit>()
                                .usernameChanged(value),
                            validator: (value) => value.trim().isEmpty
                                ? 'Username cannot be empty.'
                                : null,
                          ),
                          const SizedBox(height: 16.0),
                          TextFormField(
                            initialValue: user.bio,
                            decoration: InputDecoration(hintText: 'Bio'),
                            onChanged: (value) => context
                                .read<EditProfileCubit>()
                                .bioChanged(value),
                            validator: (value) => value.trim().isEmpty
                                ? 'Bio cannot be empty.'
                                : null,
                          ),
                          const SizedBox(height: 16.0),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 1.0,
                              textStyle: TextStyle(color: Colors.white),
                            ),
                            onPressed: () => _submitForm(context,
                                state.status == EditProfileStatus.submitting),
                            child: const Text('Update'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectProfileImage(BuildContext context) async {
    try {
      // final pickedImage = await ImageHelper.pickImageFromGallary(
      //   context: context,
      //   cropStyle: CropStyle.circle,
      //   title: 'Profile Image',
      // );

      final pickedImage =
          await ImagePicker().getImage(source: ImageSource.gallery);
      print('=============');
      print(pickedImage);
      if (pickedImage != null) {
        context
            .read<EditProfileCubit>()
            .profileImageChanged(File(pickedImage.path));
      }
    } catch (err) {
      print('This is Error =======> $err');
    }
  }

  void _submitForm(BuildContext context, bool isSubmitting) {
    if (_formKey.currentState.validate() && !isSubmitting) {
      context.read<EditProfileCubit>().submit();
    }
  }
}
