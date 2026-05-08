import { MainContent } from '../MainPage';

@Component
export struct MainHomeNavDestination {
  pathStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
  }

  aboutToDisappear(): void {
  }

  private logout(): void {
    this.pathStack.clear();
  }

  build() {
    NavDestination() {
      MainContent({
        onLogout: (): void => {
          this.logout();
        }
      })
    }
    .hideTitleBar(true)
  }
}
