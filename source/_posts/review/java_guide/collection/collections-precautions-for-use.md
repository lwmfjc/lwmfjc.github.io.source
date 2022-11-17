---
title: 集合使用注意事项
description: 集合使用注意事项
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-集合
date: 2022-10-19 17:26:07
updated: 2022-10-19 17:26:07

---

> 转载自https://github.com/Snailclimb/JavaGuide

## 集合判空

> //阿里巴巴开发手册
>
> **判断所有集合内部的元素是否为空，使用 `isEmpty()` 方法，而不是 `size()==0` 的方式。**

- isEmpty()可读性更好，且绝大部分情况下时间复杂度为O(1)

- ConcurrentHashMap的size()和isEmpty() 时间复杂度均不是O(1)

  ```java
  public int size() {
      long n = sumCount();
      return ((n < 0L) ? 0 :
              (n > (long)Integer.MAX_VALUE) ? Integer.MAX_VALUE :
              (int)n);
  }
  final long sumCount() {
      CounterCell[] as = counterCells; CounterCell a;
      long sum = baseCount;
      if (as != null) {
          for (int i = 0; i < as.length; ++i) {
              if ((a = as[i]) != null)
                  sum += a.value;
          }
      }
      return sum;
  }
  public boolean isEmpty() {
      return sumCount() <= 0L; // ignore transient negative values
  }
  ```

## 集合转Map

> //阿里巴巴开发手册
>
> **在使用 `java.util.stream.Collectors` 类的 `toMap()` 方法转为 `Map` 集合时，一定要注意当 value 为 null 时会抛 NPE 异常。**

```java
class Person {
    private String name;
    private String phoneNumber;
     // getters and setters
}

List<Person> bookList = new ArrayList<>();
bookList.add(new Person("jack","18163138123"));
bookList.add(new Person("martin",null));
// 空指针异常
bookList.stream().collect(Collectors.toMap(Person::getName, Person::getPhoneNumber));
```

java.util.stream.Collections类的toMap() ，里面使用到了Map接口的merge()方法, 调用了Objects.requireNonNull()方法判断value是否为空

## 集合遍历

> //阿里巴巴开发手册
>
> **不要在 foreach 循环里进行元素的 `remove/add` 操作。remove 元素请使用 `Iterator` 方式，如果并发操作，需要对 `Iterator` 对象加锁。**

- foreach语法底层依赖于Iterator （foreach是语法糖），不过remove/add 则是直接调用集合的方法，而不是Iterator的； 所以此时Iterator莫名发现自己元素被remove/add，就会抛出一个ConcurrentModificationException来提示用户发生了并发修改异常，即单线程状态下产生的fail-fast机制

- java8开始，可以使用Collection#removeIf()方法删除满足特定条件的元素，例子

  ```java
  List<Integer> list = new ArrayList<>();
  for (int i = 1; i <= 10; ++i) {
      list.add(i);
  }
  list.removeIf(filter -> filter % 2 == 0); /* 删除list中的所有偶数 */
  System.out.println(list); /* [1, 3, 5, 7, 9] */
  ```

- 其他的遍历数组的方法（注意是遍历，不是增加/删除）
  - 使用普通for循环

  - 使用fail-safe集合类，java.util包下面的所有集合类都是fail-fast，而java.util.concurrent包下面的所有类是fail-safe

    ```java
    //ConcurrentHashMap源码
    package java.util.concurrent;
    public class ConcurrentHashMap<K,V> extends AbstractMap<K,V>
        implements ConcurrentMap<K,V>, Serializable {}
    //List类源码
    package java.util;
    public class HashMap<K,V> extends AbstractMap<K,V>
        implements Map<K,V>, Cloneable, Serializable {
    }
    ```

    

## 集合去重

> //阿里巴巴开发手册
>
> **可以利用 `Set` 元素唯一的特性，可以快速对一个集合进行去重操作，避免使用 `List` 的 `contains()` 进行遍历去重或者判断包含操作。**

```java
// Set 去重代码示例
public static <T> Set<T> removeDuplicateBySet(List<T> data) {

    if (CollectionUtils.isEmpty(data)) {
        return new HashSet<>();
    }
    return new HashSet<>(data);
}

// List 去重代码示例
public static <T> List<T> removeDuplicateByList(List<T> data) {

    if (CollectionUtils.isEmpty(data)) {
        return new ArrayList<>();

    }
    List<T> result = new ArrayList<>(data.size());
    for (T current : data) {
        if (!result.contains(current)) {
            result.add(current);
        }
    }
    return result;
}
```

Set时间复杂度为 1 * n ，而List时间复杂度为 n * n 

```java
//Set的Contains，底层依赖于HashMap,时间复杂度为 1 
private transient HashMap<E,Object> map;
public boolean contains(Object o) {
    return map.containsKey(o);
}
//ArrayList的Contains，底层则是遍历,时间复杂度为O(n)
public boolean contains(Object o) {
    return indexOf(o) >= 0;
}
public int indexOf(Object o) {
    if (o == null) {
        for (int i = 0; i < size; i++)
            if (elementData[i]==null)
                return i;
    } else {
        for (int i = 0; i < size; i++)
            if (o.equals(elementData[i]))
                return i;
    }
    return -1;
}
```

## 集合转数组

> //阿里巴巴开发手册
>
> **使用集合转数组的方法，必须使用集合的 `toArray(T[] array)`，传入的是类型完全一致、长度为 0 的空数组。**

![image-20221020152445082](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221020152445082.png)

例子：  

```java
String [] s= new String[]{
    "dog", "lazy", "a", "over", "jumps", "fox", "brown", "quick", "A"
};
List<String> list = Arrays.asList(s);
Collections.reverse(list);
//没有指定类型的话会报错
s=list.toArray(new String[0]);
```

> 于 JVM 优化，`new String[0]`作为`Collection.toArray()`方法的参数现在使用更好，`new String[0]`就是起一个模板的作用，指定了返回数组的类型，0 是为了节省空间，因为它只是为了说明返回的类型

## 数组转集合

> //阿里巴巴开发手册
>
> **使用工具类 `Arrays.asList()` 把数组转换成集合时，不能使用其修改集合相关的方法， 它的 `add/remove/clear` 方法会抛出 `UnsupportedOperationException` 异常。**

例子及源码：  

```java
String[] myArray = {"Apple", "Banana", "Orange"};
List<String> myList = Arrays.asList(myArray);
//上面两个语句等价于下面一条语句
List<String> myList = Arrays.asList("Apple","Banana", "Orange");

//JDK源码说明[返回由指定数组支持的固定大小的列表]
/**
  *返回由指定数组支持的固定大小的列表。此方法作为基于数组和基于集合的API之间的桥梁，
  * 与 Collection.toArray()结合使用。返回的List是可序列化并实现RandomAccess接口。
  */
public static <T> List<T> asList(T... a) {
    return new ArrayList<>(a);
}
```

注意事项：  

- **1、`Arrays.asList()`是泛型方法，传递的数组必须是对象数组，而不是基本类型。**
  如果把原生数据类型数组传入，则传入的不是数组的元素，而是数组对象本身，可以使用包装类数组解决这个问题

  ```java
  int[] myArray = {1, 2, 3};
  List myList = Arrays.asList(myArray);
  System.out.println(myList.size());//1
  System.out.println(myList.get(0));//数组地址值
  System.out.println(myList.get(1));//报错：ArrayIndexOutOfBoundsException
  int[] array = (int[]) myList.get(0);
  System.out.println(array[0]);//1
  ```

- 2、使用集合的修改方法add()，remove()，clear()会抛出异常UnsupportedOperationException
  java.util.Arrays$ArrayList （Arrays里面有一个ArrayList类，该类继承了AbstractList）

  源码：  

  ```java
  public E remove(int index) {
      throw new UnsupportedOperationException();
  }
  public boolean add(E e) {
      add(size(), e);
      return true;
  }
  public void add(int index, E element) {
      throw new UnsupportedOperationException();
  }
  
  public void clear() {
      removeRange(0, size());
  }
  protected void removeRange(int fromIndex, int toIndex) {
      ListIterator<E> it = listIterator(fromIndex);
      for (int i=0, n=toIndex-fromIndex; i<n; i++) {
          it.next();
          it.remove();
      }
  }
  ```

  ![image-20221020154648530](https://raw.githubusercontent.com/lwmfjc/lwmfjc.github.io.resource/main/img/image-20221020154648530.png)

- 如何转换成正常的ArraysList呢

  1. 手动实现工具类

     ```java
     //使用泛型
     //JDK1.5+
     static <T> List<T> arrayToList(final T[] array) {
       final List<T> l = new ArrayList<T>(array.length);
     
       for (final T s : array) {
         l.add(s);
       }
       return l;
     }
     
     
     Integer [] myArray = { 1, 2, 3 };
     System.out.println(arrayToList(myArray).getClass());//class java.util.ArrayList
     ```

  2. 便捷的方法

     ```java
     //再转一次
     List list = new ArrayList<>(Arrays.asList("a", "b", "c"))
     ```

  3. **使用Java8的Stream（推荐），包括基本类型**

     ```java
     Integer [] myArray = { 1, 2, 3 };
     List myList = Arrays.stream(myArray).collect(Collectors.toList());
     //基本类型也可以实现转换（依赖boxed的装箱操作）
     int [] myArray2 = { 1, 2, 3 };
     List myList = Arrays.stream(myArray2).boxed().collect(Collectors.toList());
     ```

  4. 使用Apache Commons Colletions

     ```java
     List<String> list = new ArrayList<String>();
     CollectionUtils.addAll(list, str);
     ```

  5. 使用Java9的List.of()

     ```java
     Integer[] array = {1, 2, 3};
     List<Integer> list = List.of(array);
     ```

     

> 大部分转自https://github.com/Snailclimb/JavaGuide