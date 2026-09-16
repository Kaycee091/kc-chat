import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/safe_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/social_provider.dart';

class OnboardingWizard extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingWizard({super.key, required this.onCompleted});

  @override
  State<OnboardingWizard> createState() => _OnboardingWizardState();
}

class _OnboardingWizardState extends State<OnboardingWizard> {
  int _currentStep = 0;
  final _bioController = TextEditingController(text: 'Excited to be on KC App!');
  final _locationController = TextEditingController(text: 'San Francisco, CA');
  final Set<String> _followedCreators = {};

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Stepper Progress
          Row(
            children: List.generate(3, (index) {
              final active = index <= _currentStep;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 24),

          // Wizard Body
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                // Step 1: Avatar & Cover
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, size: 64, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Set Up Your Profile Photos',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Upload an avatar and cover picture to personalize your profile.', textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    Stack(
                      children: [
                        const SafeAvatar(
                          radius: 50,
                          imageUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400&auto=format&fit=crop&q=80',
                          name: 'New User',
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            backgroundColor: AppColors.primary,
                            radius: 18,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Avatar image updated from camera / gallery! 📷')),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Step 2: Bio & Location
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.edit_note, size: 64, color: AppColors.secondary),
                    const SizedBox(height: 16),
                    Text(
                      'Tell Us About Yourself',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _bioController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Bio / Status',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
                        prefixIcon: const Icon(Icons.location_on_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),

                // Step 3: Suggested Friends
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_add_outlined, size: 64, color: AppColors.success),
                    const SizedBox(height: 16),
                    Text(
                      'Suggested Creators to Follow',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('Connect with popular creators and friends on KC App.', textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    ListTile(
                      leading: const SafeAvatar(
                        radius: 20,
                        imageUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
                        name: 'Sophia Martinez',
                      ),
                      title: const Text('Sophia Martinez'),
                      subtitle: const Text('UI/UX Designer'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          final auth = context.read<AuthProvider>();
                          final social = context.read<SocialProvider>();
                          setState(() {
                            if (_followedCreators.contains('user_2')) {
                              _followedCreators.remove('user_2');
                            } else {
                              _followedCreators.add('user_2');
                              social.sendFriendRequest('user_2', auth);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _followedCreators.contains('user_2') ? Colors.grey.shade400 : AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_followedCreators.contains('user_2') ? 'Following' : 'Follow'),
                      ),
                    ),
                    ListTile(
                      leading: const SafeAvatar(
                        radius: 20,
                        imageUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
                        name: 'Marcus Chen',
                      ),
                      title: const Text('Marcus Chen'),
                      subtitle: const Text('Mobile Developer'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          final auth = context.read<AuthProvider>();
                          final social = context.read<SocialProvider>();
                          setState(() {
                            if (_followedCreators.contains('user_3')) {
                              _followedCreators.remove('user_3');
                            } else {
                              _followedCreators.add('user_3');
                              social.sendFriendRequest('user_3', auth);
                            }
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _followedCreators.contains('user_3') ? Colors.grey.shade400 : AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(_followedCreators.contains('user_3') ? 'Following' : 'Follow'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                TextButton(
                  onPressed: () => setState(() => _currentStep--),
                  child: const Text('Back'),
                )
              else
                const SizedBox.shrink(),
              ElevatedButton(
                onPressed: () {
                  if (_currentStep < 2) {
                    setState(() => _currentStep++);
                  } else {
                    final auth = context.read<AuthProvider>();
                    final user = auth.currentUser;
                    if (user != null) {
                      auth.updateProfile(user.copyWith(
                        bio: _bioController.text,
                        location: _locationController.text,
                      ));
                    }
                    widget.onCompleted();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(_currentStep == 2 ? 'Finish & Go to Feed' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
