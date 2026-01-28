  // Widget _buildActionButtons() {
  //   return SizedBox(
  //     height: 120, // Much smaller height
  //     width: double.infinity,
  //     child: Card(
  //       margin: EdgeInsets.zero,
  //       elevation: 2,
  //       child: Padding(
  //         padding: const EdgeInsets.all(8),
  //         child: Row(
  //           children: [
  //             Expanded(
  //               child: _buildActionButton(
  //                 icon: Icons.description,
  //                 label: 'Pending Files',
  //                 color: AppColors.secondary,
  //                 onTap: () {
  //                   RouteHelper.push(Routes.pendingFiles);
  //                 },
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: _buildActionButton(
  //                 icon: Icons.warning,
  //                 label: 'Action Required',
  //                 color: AppColors.primary,
  //                 onTap: () {
  //                   RouteHelper.push(Routes.actionRequiredFiles);
  //                 },
  //               ),
  //             ),
  //             const SizedBox(width: 12),
  //             Expanded(
  //               child: _buildActionButton(
  //                 icon: Icons.add_circle,
  //                 label: 'Create New File',
  //                 color: Colors.green,
  //                 onTap: () {
  //                   RouteHelper.push(Routes.createFile);
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildActionButton({
  //   required IconData icon,
  //   required String label,
  //   required Color color,
  //   required VoidCallback onTap,
  // }) {
  //   return InkWell(
  //     onTap: onTap,
  //     borderRadius: BorderRadius.circular(12),
  //     child: Container(
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         color: color.withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(12),
  //         border: Border.all(
  //           color: color.withOpacity(0.3),
  //         ),
  //       ),
  //       child: Column(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Icon(
  //             icon,
  //             color: color,
  //             size: 28,
  //           ),
  //           const SizedBox(height: 8),
  //           Expanded(
  //             child: Text(
  //               label,
  //               textAlign: TextAlign.center,
  //               style: TextStyle(
  //                 fontSize: 12,
  //                 fontWeight: FontWeight.w600,
  //                 color: color,
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
