class MedicalPrescription {
  List<AddMedicine>? addMedicine;
  String? notes;
  List<HomeExercise>? homeProgram;
  List<String>? attachments; // file URLs
  List<String>? images; // image URLs

  MedicalPrescription(this.addMedicine, this.notes,
      {this.homeProgram, this.attachments, this.images});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['notes'] = notes;
    if (addMedicine != null) {
      map['addMedicine'] = addMedicine?.map((v) => v.toJson()).toList();
    }
    if (homeProgram != null && homeProgram!.isNotEmpty) {
      map['homeProgram'] = homeProgram?.map((v) => v.toJson()).toList();
    }
    if (attachments != null && attachments!.isNotEmpty) {
      map['attachments'] = attachments;
    }
    if (images != null && images!.isNotEmpty) {
      map['images'] = images;
    }
    return map;
  }

  MedicalPrescription.fromJson(dynamic json) {
    notes = json['notes'];
    if (json['addMedicine'] != null) {
      addMedicine = [];
      json['addMedicine'].forEach((v) {
        addMedicine?.add(AddMedicine.fromJson(v));
      });
    }
    if (json['homeProgram'] != null) {
      homeProgram = [];
      json['homeProgram'].forEach((v) {
        homeProgram?.add(HomeExercise.fromJson(v));
      });
    }
    if (json['attachments'] != null) {
      attachments = List<String>.from(json['attachments']);
    }
    if (json['images'] != null) {
      images = List<String>.from(json['images']);
    }
  }
}

class AddMedicine {
  String? title;
  int? quantity;
  String? dosage;
  int? mealTime;
  String? notes;

  AddMedicine(
      {this.title, this.quantity, this.dosage, this.mealTime, this.notes});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['title'] = title;
    map['quantity'] = quantity;
    map['dosage'] = dosage;
    map['mealTime'] = mealTime;
    map['notes'] = notes;
    return map;
  }

  AddMedicine.fromJson(dynamic json) {
    title = json['title'];
    quantity = json['quantity'];
    dosage = json['dosage'];
    mealTime = json['mealTime'];
    notes = json['notes'];
  }
}

class HomeExercise {
  String? title;
  String? reps;
  String? sets;
  String? duration;
  String? notes;

  HomeExercise({this.title, this.reps, this.sets, this.duration, this.notes});

  Map<String, dynamic> toJson() => {
        'title': title,
        'reps': reps,
        'sets': sets,
        'duration': duration,
        'notes': notes,
      };

  HomeExercise.fromJson(dynamic json) {
    title = json['title'];
    reps = json['reps'];
    sets = json['sets'];
    duration = json['duration'];
    notes = json['notes'];
  }
}
