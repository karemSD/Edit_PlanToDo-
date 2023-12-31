import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mytest/controllers/topController.dart';
import 'package:mytest/models/User/User_task_Model.dart';
import 'package:mytest/services/auth_service.dart';
import 'package:mytest/widgets/User/task_widget.dart';

import '../../BottomSheets/bottom_sheets.dart';
import '../../Screens/Dashboard/search_bar_animation.dart';
import '../../Values/values.dart';
import '../../constants/app_constans.dart';
import '../../constants/back_constants.dart';
import '../../controllers/categoryController.dart';
import '../../controllers/statusController.dart';
import '../../controllers/user_task_controller.dart';
import '../../models/statusmodel.dart';
import '../../models/task/UserTaskCategory_model.dart';

import '../../services/collectionsrefrences.dart';
import '../Dashboard/create_user_task.dart';
import '../Dashboard/dashboard_add_icon.dart';
import '../Navigation/app_header.dart';
import '../Snackbar/custom_snackber.dart';

class FatherTasks extends StatefulWidget {
  FatherTasks({
    Key? key,
    required this.categoryModel,
    required this.fatherTaskModel,
    required this.documentReference,
  }) : super(key: key);

  final UserTaskCategoryModel categoryModel;
  final UserTaskModel fatherTaskModel;
  DocumentReference documentReference;

  @override
  State<FatherTasks> createState() => _FatherTasksState();
}

enum TaskSortOption {
  name,
  createDate,
  updatedDate,
  startDate,
  endDate,
  importance
  // Add more sorting options if needed
}

class _FatherTasksState extends State<FatherTasks> {
  TaskSortOption selectedSortOption = TaskSortOption.name;
  int crossAxisCount = 1; // Variable for crossAxisCount
  bool sortAscending = true; // Variable for sort order

  String _getSortOptionText(TaskSortOption option) {
    switch (option) {
      case TaskSortOption.name:
        return 'Name';
      case TaskSortOption.updatedDate:
        return 'Updated Date';
      case TaskSortOption.createDate:
        return 'Created Date';
      case TaskSortOption.startDate:
        return 'Start Date';
      case TaskSortOption.endDate:
        return 'End Date';
      case TaskSortOption.importance:
        return 'Importance';
      // Add cases for more sorting options if needed
      default:
        return '';
    }
  }

  void toggleCrossAxisCount() {
    setState(() {
      crossAxisCount =
          crossAxisCount == 1 ? 2 : 1; // Toggle the crossAxisCount value
    });
  }

  void toggleSortOrder() {
    setState(() {
      sortAscending = !sortAscending; // Toggle the sort order
    });
  }

  TaskCategoryController userTaskCategoryController =
      Get.put(TaskCategoryController());
  TextEditingController editingController = TextEditingController();
  UserTaskController taskController = Get.put(UserTaskController());
  String search = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: DashboardAddButton(
        iconTapped: () {
          _createTask2();
        },
      ),
      backgroundColor: HexColor.fromHex("#181a1f"),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: Utils.screenWidth * 0.04, // Adjust the percentage as needed
              right: Utils.screenWidth * 0.04,
            ),
            child: SafeArea(
              child: TaskezAppHeader(
                title:
                    "${AppConstants.task_key.tr} :${widget.fatherTaskModel.name?.toUpperCase()}  ${AppConstants.tasks_key.tr}",
                widget: MySearchBarWidget(
                  searchWord:
                      "${widget.fatherTaskModel.name?.toUpperCase()} ${AppConstants.tasks_key.tr}",
                  editingController: editingController,
                  onChanged: (String value) {
                    setState(() {
                      print(search);
                      search = value;
                    });
                  },
                ),
              ),
            ),
          ),
          AppSpaces.verticalSpace20,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 20.0, left: 20.0),
                padding: const EdgeInsets.only(right: 20.0, left: 20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButton<TaskSortOption>(
                  value: selectedSortOption,
                  onChanged: (TaskSortOption? newValue) {
                    setState(() {
                      selectedSortOption = newValue!;
                      // Implement the sorting logic here
                    });
                  },
                  items: TaskSortOption.values.map((TaskSortOption option) {
                    return DropdownMenuItem<TaskSortOption>(
                      value: option,
                      child: Text(
                        _getSortOptionText(option),
                        style: const TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    );
                  }).toList(),

                  // Add extra styling
                  icon: const Icon(
                    Icons.arrow_drop_down,
                    size: 35,
                  ),
                  underline: const SizedBox(),
                ),
              ),
              IconButton(
                icon: Icon(
                  sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                ),
                onPressed: toggleSortOrder, // Toggle the sort order
              ),
              IconButton(
                icon: const Icon(
                  Icons.grid_view,
                  color: Colors.white,
                ),
                onPressed:
                    toggleCrossAxisCount, // Toggle the crossAxisCount value
              ),
            ],
          ),
          AppSpaces.verticalSpace20,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left:
                    Utils.screenWidth * 0.04, // Adjust the percentage as needed
                right: Utils.screenWidth * 0.04,
              ),
              child: MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: StreamBuilder<QuerySnapshot<UserTaskModel>>(
                  stream: taskController.getChildTasksStream(
                    taskFatherId: widget.documentReference,
                  ),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot<UserTaskModel>> snapshot) {
                    if (snapshot.hasData) {
                      int taskCount = snapshot.data!.docs.length;
                      List<UserTaskModel> list = [];
                      if (taskCount > 0) {
                        if (search.isNotEmpty) {
                          snapshot.data!.docs.forEach((element) {
                            UserTaskModel taskCategoryModel = element.data();
                            if (taskCategoryModel.name!
                                .toLowerCase()
                                .contains(search)) {
                              list.add(taskCategoryModel);
                            }
                          });
                        } else {
                          snapshot.data!.docs.forEach((element) {
                            UserTaskModel taskCategoryModel = element.data();
                            list.add(taskCategoryModel);
                          });
                        }
                        switch (selectedSortOption) {
                          case TaskSortOption.name:
                            list.sort((a, b) => a.name!.compareTo(b.name!));
                            break;
                          case TaskSortOption.createDate:
                            list.sort(
                                (a, b) => a.createdAt.compareTo(b.createdAt));
                            break;
                          case TaskSortOption.updatedDate:
                            list.sort(
                                (a, b) => b.updatedAt.compareTo(a.updatedAt));
                          case TaskSortOption.endDate:
                            list.sort(
                                (a, b) => b.endDate!.compareTo(a.endDate!));
                          case TaskSortOption.startDate:
                            list.sort(
                                (a, b) => b.startDate.compareTo(a.startDate));
                          case TaskSortOption.importance:
                            list.sort(
                                (a, b) => b.importance.compareTo(a.importance));
                            break;
                          // Add cases for more sorting options if needed
                        }
                        if (!sortAscending) {
                          list = list.reversed
                              .toList(); // Reverse the list for descending order
                        }
                        return GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 10,
                            mainAxisExtent: 220,
                            crossAxisSpacing: 10,
                          ),
                          itemBuilder: (_, index) {
                            return CardTask(
                              userTaskCategoryId: widget.categoryModel.id,
                              onPrimary: Colors.white,
                              primary: HexColor.fromHex(list[index].hexcolor),
                              task: list[index],
                              userFatherId: widget.documentReference,
                            );
                          },
                          itemCount: list.length,
                        );
                      } else {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                Icons.task,
                                size: 100,
                                color: HexColor.fromHex("#999999"),
                              ),
                              AppSpaces.verticalSpace10,
                              Text(
                                "No Tasks Found",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: HexColor.fromHex("#999999"),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              AppSpaces.verticalSpace10,
                              Text(
                                "Add a task to get started",
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    color: HexColor.fromHex("#999999"),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              AppSpaces.verticalSpace10,
                            ],
                          ),
                        );
                      }
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text("Error: ${snapshot.error}"),
                      );
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _createTask2() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      context: context,
      builder: (BuildContext context) {
        return CreateUserTask(
          addLateTask: (
              {required int priority,
              required String taskName,
              required DateTime startDate,
              required DateTime dueDate,
              required String? desc,
              required String color}) async {
            if (startDate.isAfter(dueDate) ||
                startDate.isAtSameMomentAs(dueDate)) {
              CustomSnackBar.showError("start date cannot be after end date");
              return;
            }

            try {
              StatusController statusController = Get.put(StatusController());
              StatusModel statusModel = await statusController.getStatusByName(
                  status: statusNotStarted);

              UserTaskModel userTaskModel = UserTaskModel.firestoreConstructor(
                  colorParameter: color,
                  userId: AuthService.instance.firebaseAuth.currentUser!.uid,
                  folderId: widget.categoryModel.id,
                  taskFatherId: null,
                  descriptionParameter: desc!,
                  idParameter: usersTasksRef.doc().id,
                  nameParameter: taskName,
                  statusIdParameter: statusModel.id,
                  importanceParameter: priority,
                  createdAtParameter: DateTime.now(),
                  updatedAtParameter: DateTime.now(),
                  startDateParameter: startDate,
                  endDateParameter: dueDate);
              await UserTaskController()
                  .addUserLateTask(userTaskModel: userTaskModel);
              CustomSnackBar.showSuccess(
                  "${AppConstants.the_task_key} ${userTaskModel.name} ${AppConstants.added_successfully_key}");
              Get.key.currentState!.pop();
            } catch (e) {
              CustomSnackBar.showError(e.toString());
            }
          },
          isUserTask: true,
          addTask: ({
            required int priority,
            required String taskName,
            required DateTime startDate,
            required DateTime dueDate,
            required String? desc,
            required String color,
          }) async {
            if (startDate.isAfter(dueDate) ||
                startDate.isAtSameMomentAs(dueDate)) {
              CustomSnackBar.showError("start date cannot be after end date");
              return;
            }
            try {
              StatusController statusController = Get.put(StatusController());
              StatusModel statusModel = await statusController.getStatusByName(
                  status: statusNotStarted);
              DocumentReference? taskfatherid;

              DocumentSnapshot documentReference =
                  await statusController.getDocById(
                      reference: usersTasksRef, id: widget.fatherTaskModel.id);
              UserTaskModel fatherModel =
                  documentReference.data() as UserTaskModel;
              taskfatherid = documentReference.reference;
              if (startDate.isBefore(fatherModel.startDate) ||
                  dueDate.isAfter(fatherModel.endDate!)) {
                throw Exception(
                    "son task start and end date should be between start and end date of the father task");
              }
              UserTaskModel userTaskModel = UserTaskModel(
                  hexColorParameter: color,
                  userIdParameter:
                      AuthService.instance.firebaseAuth.currentUser!.uid,
                  folderIdParameter: widget.categoryModel.id,
                  taskFatherIdParameter: taskfatherid,
                  descriptionParameter: desc!,
                  idParameter: usersTasksRef.doc().id,
                  nameParameter: taskName,
                  statusIdParameter: statusModel.id,
                  importanceParameter: priority,
                  createdAtParameter: DateTime.now(),
                  updatedAtParameter: DateTime.now(),
                  startDateParameter: startDate,
                  endDateParameter: dueDate);
              await UserTaskController()
                  .adddUserTask(userTaskModel: userTaskModel);
            } catch (e) {
              CustomSnackBar.showError(e.toString());
            }
          },
          checkExist: ({required String name}) async {
            // DocumentReference? taskfatherid;

            // DocumentSnapshot documentReference = await StatusController()
            //     .getDocById(
            //         reference: usersTasksRef, id: widget.fatherTaskModel.id);
            // taskfatherid = documentReference.reference;
            return TopController().existByTow(
                reference: usersTasksRef,
                value: name,
                field: nameK,
                value2: widget.documentReference,
                field2: taskFatherIdK);
          },
          isEditMode: false,
        );
      },
    );
  }
}
