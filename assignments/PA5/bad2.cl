class A {};
class Main {
    y : Object;
    z : Int;
    test1():Int{
        case y of
            h : Int => 1;
        esac
    };
    test2():Int {
        case z of
            h : Bool => 1;
            h : String => 1;
        esac
    };
    main():Int { 0 };
};