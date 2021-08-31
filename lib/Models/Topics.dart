import 'package:online_classroom/Models/Assignment.dart';

class Topic{
  String? title;
  int? test;
  int? assignments;
  List<Assignment> assign = [];

  Topic(this.title,this.test,this.assignments, this.assign);
}