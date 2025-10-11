import os

# Define the folder structure
structure = {
    "lib": [
        "main.dart",
        "screens/onboarding/onboarding_screen.dart",
        "screens/onboarding/onboarding_page_1.dart",
        "screens/onboarding/onboarding_page_2.dart",
        "screens/onboarding/onboarding_page_3.dart",
        "screens/auth/auth_choice_screen.dart",
        "screens/auth/sign_up_screen.dart",
        "screens/auth/log_in_screen.dart",
        "screens/auth/goal_setup_screen.dart",
        "widgets/page_indicator.dart",
        "widgets/custom_button.dart",
        "widgets/custom_text_field.dart",
        "widgets/auth_button.dart",
        "theme/app_colors.dart",
        "theme/app_text_styles.dart",
        "theme/app_theme.dart",
        "utils/validators.dart",
        "providers/onboarding_provider.dart",
        "providers/auth_provider.dart",
    ]
}

def create_structure(base_path, structure):
    for folder, files in structure.items():
        for file_path in files:
            full_path = os.path.join(base_path, folder, file_path)
            os.makedirs(os.path.dirname(full_path), exist_ok=True)
            # Create empty Dart files if they don’t exist
            if not os.path.exists(full_path):
                with open(full_path, "w", encoding="utf-8") as f:
                    f.write("// " + os.path.basename(full_path))
                print(f"Created: {full_path}")

if __name__ == "__main__":
    base_dir = os.getcwd()  # current working directory
    create_structure(base_dir, structure)
    print("\n✅ Flutter project structure created successfully!")
