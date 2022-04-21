import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  const CustomButton({
    required this.onTap,
    required this.title,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 7.h,
          width: 90.w,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12), color: Colors.green),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.green,
                fontSize: 16.sp),
          ),
        ),
      ),
    );
  }
}
