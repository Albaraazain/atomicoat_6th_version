import 'package:flutter/material.dart';
import '../providers/spare_parts_provider.dart';
import '../models/spare_part.dart';
import 'package:provider/provider.dart';

class SparePartsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: Text('Spare Parts Inventory'),
      ),
      body: Consumer<SparePartsProvider>(
        builder: (ctx, sparePartsProvider, _) {
          if (sparePartsProvider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (sparePartsProvider.error != null) {
            return Center(
              child: Text('An error occurred: ${sparePartsProvider.error}'),
            );
          }
          return ListView.builder(
            itemCount: sparePartsProvider.spareParts.length,
            itemBuilder: (ctx, index) {
              final part = sparePartsProvider.spareParts[index];
              return Card(
                child: ListTile(
                  title: Text(part.name),
                  subtitle: Text('Quantity: ${part.quantity}'),
                  trailing: part.isLowStock
                      ? Icon(Icons.warning, color: Colors.orange)
                      : null,
                  onTap: () => _showSparePartDetails(context, part),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSparePartDialog(context),
        child: Icon(Icons.add),
        tooltip: 'Add new spare part',
      ),
    );
  }

  void _showSparePartDetails(BuildContext context, SparePart part) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(part.name),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Part Number: ${part.partNumber}'),
            Text('Quantity: ${part.quantity}'),
            Text('Minimum Stock Level: ${part.minimumStockLevel}'),
            Text('Supplier: ${part.supplier}'),
            Text('Notes: ${part.notes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Close'),
          ),
          ElevatedButton(
            onPressed: () => _showUpdateQuantityDialog(context, part),
            child: Text('Update Quantity'),
          ),
        ],
      ),
    );
  }

  void _showUpdateQuantityDialog(BuildContext context, SparePart part) {
    final quantityController = TextEditingController(text: part.quantity.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Update Quantity'),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: 'New Quantity'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newQuantity = int.tryParse(quantityController.text);
              if (newQuantity != null) {
                Provider.of<SparePartsProvider>(context, listen: false)
                    .updateSparePartQuantity(part.id, newQuantity);
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              }
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showAddSparePartDialog(BuildContext context) {
    // TODO: Implement add spare part dialog
  }
}