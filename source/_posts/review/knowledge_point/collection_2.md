---
title: 集合_2
description: 集合_2
categories:
  - 学习
tags:
  - '复习'
  - '复习--知识点' 
date: 2022-10-18 08:54:49
updated: 2022-10-18 08:54:49

---



## Map

- HashMap和Hashtable的区别
  - HashMap是非线程安全的，Hashtable是线程安全的，因为Hashtable内部方法都经过synchronized修饰（不过要保证线程安全一般用ConcurrentHashMap）
  - 由于加了synchronized修饰，HashTable效率没有HashMap高
  - HashMap可以存储null的key和value，但null作为key的键只能由一个；HashTable不允许有null键和null值
  - 初始容量及每次扩容
    - Hashtable默认初始大小11，之后扩容为2n+1;HashMap初始大小16，之后扩容2n
    - 如果指定初始大小，HashTable直接使用初始大小  
      而HashMap使用2的幂作为哈希表的大小（我猜是大于初始大小的最小2的n次方）**Returns a power of two size for the given target capacity.**
  - 底层数据结构
    - JDK1.8之后HashMap解决哈希冲突时，当链表大于阈值（默认8）时，将链表转为红黑树（转换前判断，如果当前数组长度小于64，则先进行数组扩容，而不转成红黑树），以减少搜索时间
  
- HashMap和hashSet区别

  - HashSet底层就是HashMap实现的
  - HashMap：实现了Map接口；存储键值对；调用put()向map中添加元素；**HashMap使用键（key）计算**
  - HashSet：实现Set接口；仅存储对象；调用add()方法向Set中添加元素；HashSet使用成员对象计算hashCode，对于不相等两个对象来说 hashcode也可能相同，所以还要再借助equals()方法判断对象相等性

- HashMap和TreeMap
  navigable 英[ˈnævɪɡəbl] 通航的，可航行的  
  HashMap和TreeMap都继承自AbstractMap  
  TreeMap还实现了NavigableMap （**对集合内元素搜索**）和SortedMap（对集合内元素**根据键排序**，默认key升序，可指定排序的比较器）接口  
  示例：

  ```java
  /**
   * @author shuang.kou
   * @createTime 2020年06月15日 17:02:00
   */
  public class Person {
      private Integer age;
  
      public Person(Integer age) {
          this.age = age;
      }
  
      public Integer getAge() {
          return age;
      }
  
  
      public static void main(String[] args) {
          TreeMap<Person, String> treeMap = new TreeMap<>(new Comparator<Person>() {
              @Override
              public int compare(Person person1, Person person2) {
                  int num = person1.getAge() - person2.getAge();
                  return Integer.compare(num, 0);
              }
          });
          treeMap.put(new Person(3), "person1");
          treeMap.put(new Person(18), "person2");
          treeMap.put(new Person(35), "person3");
          treeMap.put(new Person(16), "person4");
          treeMap.entrySet().stream().forEach(personStringEntry -> {
              System.out.println(personStringEntry.getValue());
          });
      }
  }
  //输出
  /**person1
  person4
  person2
  person3
  **/
  ```

  

## Collections工具类

## Java集合使用注意事项总结



