import { TimerView } from '../views/TimerView';

@Entry
@Component
struct Index {
  build() {
    RelativeContainer() {
      TimerView()
    }
    .height('100%')
    .width('100%')
  }
}
