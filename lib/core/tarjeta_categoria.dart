import 'package:flutter/material.dart';

class TarjetaCategoria {
  static Widget construir(Map<String, dynamic> cat, int index,
      Function(Map<String, dynamic>) mostrarDetalle) {
    return GestureDetector(
      onTap: () => cat['estado'] ? mostrarDetalle(cat) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: cat['estado'] ? cat['color'] : Colors.grey,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.category, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          cat['nombre'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'HelveticaRounded',
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: Colors.white),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['descripcion'],
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cat['color'],
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    color: cat['color'],
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
