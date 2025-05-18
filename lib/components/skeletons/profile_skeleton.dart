import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MastodonProfileSkeleton extends StatelessWidget {
  final bool isBottomSheet;

  const MastodonProfileSkeleton({super.key, this.isBottomSheet = false});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey[300]!;
    final highlightColor = Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isBottomSheet)
                Container(
                  width: double.infinity,
                  height: 150.0,
                  color: Colors.white,
                ),
              if (!isBottomSheet) SizedBox(height: 16),
              Row(
                crossAxisAlignment: isBottomSheet ? CrossAxisAlignment.center : CrossAxisAlignment.end,
                children: [
                  Container(
                    width: isBottomSheet ? 60.0 : 100.0,
                    height: isBottomSheet ? 60.0 : 100.0,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 16),
                  if (isBottomSheet)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 150, height: 20, color: Colors.white),
                          SizedBox(height: 8),
                          Container(width: 100, height: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  if (!isBottomSheet) Spacer(),
                  if (!isBottomSheet)
                    Container(width: 100, height: 36, color: Colors.white, margin: EdgeInsets.only(bottom: isBottomSheet ? 0 : 50)),
                ],
              ),
              if (!isBottomSheet) SizedBox(height: isBottomSheet ? 0 : 8),
              if (!isBottomSheet)
                Padding(
                  padding: EdgeInsets.only(top: isBottomSheet ? 16 : 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: MediaQuery.of(context).size.width * 0.6, height: 24.0, color: Colors.white),
                      SizedBox(height: 8),
                      Container(width: MediaQuery.of(context).size.width * 0.4, height: 18.0, color: Colors.white),
                    ],
                  ),
                ),
              if (isBottomSheet) SizedBox(height: 16),
              SizedBox(height: 16),
              Container(width: double.infinity, height: 16.0, color: Colors.white),
              SizedBox(height: 8),
              Container(width: double.infinity, height: 16.0, color: Colors.white),
              SizedBox(height: 8),
              Container(width: MediaQuery.of(context).size.width * 0.7, height: 16.0, color: Colors.white),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(3, (_) => Column(
                  children: [
                    Container(width: 50, height: 20, color: Colors.white),
                    SizedBox(height: 4),
                    Container(width: 70, height: 14, color: Colors.white),
                  ],
                )),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
