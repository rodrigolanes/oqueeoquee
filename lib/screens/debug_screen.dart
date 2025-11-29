import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/device_utils.dart';

class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String? _deviceId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await DeviceUtils.getAndroidId();
    setState(() {
      _deviceId = id;
      _isLoading = false;
    });
  }

  void _copyToClipboard() {
    if (_deviceId != null) {
      Clipboard.setData(ClipboardData(text: _deviceId!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ID copiado para área de transferência!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAllowed = DeviceUtils.allowedDeviceIds.contains(_deviceId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Informações do Dispositivo'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAllowed ? Icons.verified_user : Icons.phone_android,
                      size: 80,
                      color: isAllowed ? Colors.green : Colors.orange,
                    ),
                    const SizedBox(height: 32),
                    if (isAllowed) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Dispositivo Autorizado',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Text(
                      'Android ID:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use este ID para autorizar este dispositivo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[400]!),
                      ),
                      child: SelectableText(
                        _deviceId ?? 'ID não disponível',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('Copiar ID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.info_outline,
                                    color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                Text(
                                  'Como autorizar dispositivo',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              '1. Copie o Android ID acima\n'
                              '2. Adicione em lib/utils/device_utils.dart\n'
                              '3. Na lista allowedDeviceIds\n'
                              '4. Faça rebuild do app\n\n'
                              'Apenas dispositivos autorizados podem criar/editar piadas.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
