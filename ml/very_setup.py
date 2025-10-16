"""
Quick setup verification script
Run this first to check if everything is installed correctly
"""

import os
import warnings
import sys
import subprocess

# Suppress TensorFlow warnings
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'
warnings.filterwarnings('ignore', category=UserWarning, module='google.protobuf')

print("="*80)
print(" "*25 + "SETUP VERIFICATION")
print("="*80 + "\n")

print(f"Python Version: {sys.version.split()[0]}")
print(f"Python Executable: {sys.executable}\n")

# Test imports one by one
tests = []

def test_import(module_name, import_name=None):
    import_name = import_name or module_name
    try:
        module = __import__(import_name)
        version = getattr(module, '__version__', 'Unknown')
        print(f"✓ {module_name} {version} - OK")
        tests.append((module_name, True))
    except ImportError as e:
        print(f"✗ {module_name} - FAILED: {e}")
        tests.append((module_name, False))

# Core ML packages
test_import("TensorFlow", "tensorflow")
test_import("Keras", "tensorflow.keras")
test_import("NumPy", "numpy")
test_import("Pandas", "pandas")
test_import("Scikit-learn", "sklearn")
test_import("Joblib", "joblib")
# Optional
test_import("Matplotlib", "matplotlib")

# Summary
print("\n" + "="*80)
print(" "*30 + "SUMMARY")
print("="*80 + "\n")

passed = sum(1 for _, status in tests[:-1] if status)  # Exclude matplotlib
total = len(tests) - 1

print(f"Passed: {passed}/{total} required packages")

if passed == total:
    print("\n✓ ALL CHECKS PASSED!")
    print("\nYou're ready to run:")
    print("  python train_model.py")
    print("  python test_model.py")
else:
    print("\n✗ SOME PACKAGES MISSING")
    print("\nTo install missing packages, run:")
    print("  pip install tensorflow numpy pandas scikit-learn joblib matplotlib")
    failed = [name for name, status in tests[:-1] if not status]
    if failed:
        print(f"\nMissing: {', '.join(failed)}")

print("\n" + "="*80)

# Additional system info
print("\n📊 System Information:")
try:
    import platform
    print(f"  OS: {platform.system()} {platform.release()}")
    print(f"  Architecture: {platform.machine()}")
    print(f"  Processor: {platform.processor()}")
except:
    pass

# -------------------------
# GPU detection
# -------------------------
def check_tf_gpus():
    import tensorflow as tf
    gpus = tf.config.list_physical_devices('GPU')
    if gpus:
        print(f"\n🎮 TensorFlow detected {len(gpus)} GPU(s):")
        for i, gpu in enumerate(gpus, 1):
            details = tf.config.experimental.get_device_details(gpu)
            name = details.get('device_name', 'Unknown GPU')
            compute_capability = details.get('compute_capability', 'N/A')
            memory_limit = details.get('memory_limit', 'N/A')
            print(f"  • GPU {i}: {name}")
            print(f"    - Compute Capability: {compute_capability}")
            if memory_limit != 'N/A':
                print(f"    - Memory Limit: {memory_limit / (1024**2):.0f} MB")
        return True
    return False

def check_nvidia_smi():
    try:
        result = subprocess.run(["nvidia-smi", "-L"], capture_output=True, text=True, check=True)
        gpus = result.stdout.strip().split("\n")
        if gpus and gpus[0]:
            print(f"\n💡 NVIDIA GPU detected via nvidia-smi ({len(gpus)} GPU(s)):")
            for gpu in gpus:
                print(f"  • {gpu}")
            return True
    except Exception:
        return False

print("\n" + "="*80)
print(" "*25 + "GPU CHECK")
print("="*80 + "\n")

tf_gpu = check_tf_gpus()
nvidia_gpu = check_nvidia_smi()

if not tf_gpu and nvidia_gpu:
    print("\n⚠ GPU exists but TensorFlow cannot access it.")
  
elif not tf_gpu and not nvidia_gpu:
    print("\n💻 No GPU detected, running on CPU")

print("\n" + "="*80)
