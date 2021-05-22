class AutoView {
  int classID;
  String title;

  AutoView(this.classID, this.title);

  static List<AutoView> getList() {

    List<AutoView> list = new List<AutoView>();
    list.add(AutoView(1, 'Автокран'));
    return list;
  }
}