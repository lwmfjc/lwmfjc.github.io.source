---
title:  ArrayList源码
description: ArrayList源码
categories:
  - 学习
tags:
  - 复习
  - 复习-javaGuide
  - 复习-javaGuide-集合
date: 2022-10-20 17:01:47
updated: 2022-10-20 17:01:47

---

> 转载自https://github.com/Snailclimb/JavaGuide （添加小部分笔记）感谢作者!

## 简介

- 底层是数组队列，相当于**动态数组**，能**动态增长**，可以在添加大量元素前先使用**ensureCapacity**来增加ArrayList容量，**减少递增式再分配的数量**
  源码：  

    ```java
  public class ArrayList<E> extends AbstractList<E>
                implements List<E>, RandomAccess, Cloneable, java.io.Serializable{ }
    ```

    1. Random Access，标志接口，表明这个接口的List集合支持**快速随机访问**，这里是指可**通过元素序号快速访问**
    2. 实现Cloneable接口，能**被克隆**
    3. 实现java.io.Serializable，**支持序列化**

- ArrayList和Vector区别

  - ArrayList和Vector都是List的实现类，Vector出现的比较早，底层都是Object[] 存储
  - ArrayList线程不安全（适合频繁查找，线程不安全 ）
  - Vector 线程安全的

- ArrayList与LinkedList区别

  - 都是**不同步**的，即不保证线程安全
  - ArrayList底层为Object数组；LinkedList底层使用**双向链表数据结构**(1.6之前为循环链表，1.7取消了循环)
  - 插入和删除是否受元素位置影响
    
    - ArrayList采用数组存储，所以插入和删除元素的时间复杂度受元素位置影响[ 默认增加到末尾，O(1) ; 在指定位置，则O(n) , 要往后移动]
    
    - LinkedList采用链表存储，所以对于add(E e)方法，还是O(1)；如果是在指定位置插入和删除，则为O(n)  因为需要遍历将指针移动到指定位置
    
      ```java
      //LinkedList默认添加到最后
      public boolean add(E e) {
              linkLast(e);
              return true;
      }
      ```
    
    - LinkedList**不支持高效随机元素访问**，而ArrayList支持（通过get(int index))
    
    - 内存空间占用
      ArrayList的空间浪费主要体现在list列表的结尾会预留一定的容量空间，而LinkedList的空间花费在，每个元素都需要比ArrayList更多空间（要存放直接前驱和直接后继以及(当前)数据)

## 3. 扩容机制分析 ( JDK8 )

1. ArrayList的构造函数

   - 三种方式初始化，构造方法源码
   - 空参，指定大小，指定集合 （如果集合类型非Object[].class，则使用Arrays.copyOf转为Object[].class)
   - 以无参构造方式创建ArrayList时，实际上初始化赋值的是空数组；当真正操作时才分配容量，即添加第一个元素时扩容为10

   ```java
   
    /**
        * 默认初始容量大小
        */
       private static final int DEFAULT_CAPACITY = 10;
   
   
       private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};
   
       /**
        *默认构造函数，使用初始容量10构造一个空列表(无参数构造)
        */
       public ArrayList() {
           this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
       }
   
       /**
        * 带初始容量参数的构造函数。（用户自己指定容量）
        */
       public ArrayList(int initialCapacity) {
           if (initialCapacity > 0) {//初始容量大于0
               //创建initialCapacity大小的数组
               this.elementData = new Object[initialCapacity];
           } else if (initialCapacity == 0) {//初始容量等于0
               //创建空数组
               this.elementData = EMPTY_ELEMENTDATA;
           } else {//初始容量小于0，抛出异常
               throw new IllegalArgumentException("Illegal Capacity: "+
                                                  initialCapacity);
           }
       }
   
   
      /**
       *构造包含指定collection元素的列表，这些元素利用该集合的迭代器按顺序返回
       *如果指定的集合为null，throws NullPointerException。
       */
        public ArrayList(Collection<? extends E> c) {
           elementData = c.toArray();
           if ((size = elementData.length) != 0) {
               // c.toArray might (incorrectly) not return Object[] (see 6260652)
               if (elementData.getClass() != Object[].class)
                   elementData = Arrays.copyOf(elementData, size, Object[].class);
           } else {
               // replace with empty array.
               this.elementData = EMPTY_ELEMENTDATA;
           }
       }
   ```

2. 以无参构造参数函数为例
   **先看下面的 add()方法扩容**

   得到最小扩容量( 如果空数组则为10，否则原数组大小+1 )--->确定是否扩容【**minCapacity > 此时的数组大小**】--->
   真实进行扩容 【 grow(int minCapacity) 】

   - 扩容的前提是  数组最小扩容 > 数组实际大小 

   - 几个名词：oldCapacity，newCapacity (oldCapacity * 1.5 )，minCapacity，MAX_ARRAY_SIZE ,INT_MAX 

     > 对于MAX_ARRAY_SIZE的解释：  
     > /** 要分配的数组的最大大小。
     >   一些 VM 在数组中保留一些标题字。
     >   尝试分配更大的数组可能会导致 OutOfMemoryError：请求的数组大小超过 VM 限制**/
     > Integer.MAX_VALUE = Ingeger.MAX_VALUE - 8 ; 

     ```capacity 英[kəˈpæsəti]```
     这个方法最后是要用newCapacity扩容的，所以要给他更新可用的值，也就是：  

     1. 如果扩容后还比minCapacity 小，那就把newCapacity更新为minCapacity的值

     2. 如果比MAX_ARRAY_SIZE还大，那就超过范围了

        得通过hugeCapacity(minCapcacity) ，即minCapacity和MAX_ARRAY_SIZE来设置newCapacity

     3. -> 这里有点绕，看了也记不住-----其实前面第1步，就是说我至少需要minCapcacity的数，但是如果newCapacity (1.5 * oldCapacity )比MAX_ARRAY_SIZE：如果实际需要的容量 (miniCapacity > MAX_ARRAY_SIZE , 那就直接取Integer.MAX_VALUE ；如果没有，那就取MAX_ARRAY_SIZE )

   ```java
   //add方法，先扩容，再赋值（实际元素长度最后）
       /**
        * 将指定的元素追加到此列表的末尾。
        */
       public boolean add(E e) {
      //添加元素之前，先调用ensureCapacityInternal方法
           ensureCapacityInternal(size + 1);  // Increments modCount!!  			//jdk11 移除了该方法，第一次进入时size为0
           //这里看到ArrayList添加元素的实质就相当于为数组赋值
           elementData[size++] = e;
           return true;
       }
   ```

   ```java
   //ensureCapacityInternal,if语句说明第一次add时，取当前容量和默认容量的最大值作为扩容量
      //**得到最小扩容量**
       private void ensureCapacityInternal(int minCapacity) {
           if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
               // 获取默认的容量和传入参数的较大值
               //当 要 add(E) 进第 1 个元素时，minCapacity 为 1，在 Math.max()方法比较后，minCapacity 为 10。
               //为什么不直接取DEFAULT_CAPACITY,因为这个方法不只是add(E )会用到，
               //其次addAll(Collection<? extends E> c)也用到了
               minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
           }
   
           ensureExplicitCapacity(minCapacity);
       }
   ```

   ```java
   //ensureExplicitCapacity 判断是否扩容
     //判断是否需要扩容
       private void ensureExplicitCapacity(int minCapacity) {
           modCount++;
   
           // overflow-conscious code
           if (minCapacity - elementData.length > 0)
               //调用grow方法进行扩容，调用此方法代表已经开始扩容了
               grow(minCapacity);
       }
   /*
    if语句表示，当minCapacity（数组实际*需要*容量的大小）大于实际容量则进行扩容
    添加第1个元素的时候，会进入grow方法，直到添加第10个元素 都不会再进入grow()方法
    当添加第11个元素时，minCapacity(11)比elementData.length(10)大，进入扩容
   */
   ```

   ```java
   // grow()方法
        /**
        * 要分配的最大数组大小
        */
       private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
   
       /**
        * ArrayList扩容的核心方法。
        */
       private void grow(int minCapacity) {
           // oldCapacity为旧容量，newCapacity为新容量
           int oldCapacity = elementData.length;
           //将oldCapacity 右移一位，其效果相当于oldCapacity /2，
           //我们知道位运算的速度远远快于整除运算，整句运算式的结果就是将新容量更新为旧容量的1.5倍，
           int newCapacity = oldCapacity + (oldCapacity >> 1);
           //然后检查新容量是否大于最小需要容量，若还是小于最小需要容量，那么就把最小需要容量当作数组的新容量[1.5倍扩容后还小于，说明一次添加的大于1.5倍扩容后的大小]
           if (newCapacity - minCapacity < 0)
               newCapacity = minCapacity;
          // 如果新容量大于 MAX_ARRAY_SIZE,进入(执行) `hugeCapacity()` 方法来比较 minCapacity 和 MAX_ARRAY_SIZE，
          //如果minCapacity大于最大容量，则新容量则为`Integer.MAX_VALUE`，否则，新容量大小则为 MAX_ARRAY_SIZE 即为 `Integer.MAX_VALUE - 8`。
           if (newCapacity - MAX_ARRAY_SIZE > 0)
               newCapacity = hugeCapacity(minCapacity);
           // minCapacity is usually close to size, so this is a win:
           elementData = Arrays.copyOf(elementData, newCapacity);
       }
   /*
    进入真正的扩容
   int newCapacity = oldCapacity + (oldCapacity >> 1),所以 ArrayList 每次扩容之后容量都会变为原来的 1.5 倍左右（oldCapacity 为偶数就是 1.5 倍，否则是 1.5 倍左右）！ 奇偶不同，比如 ：10+10/2 = 15, 33+33/2=49。如果是奇数的话会丢掉小数；右移运算会比普通运算符快很多
   */
   ```

3. 扩展

   - java 中的 `length`属性是针对数组说的,比如说你声明了一个数组,想知道这个数组的长度则用到了 length 这个属性.
   - java 中的 `length()` 方法是针对字符串说的,如果想看这个字符串的长度则用到 `length()` 这个方法.
   - java 中的 `size()` 方法是针对泛型集合说的,如果想看这个泛型有多少个元素,就调用此方法来查看!

4. hugeCapacity
   当新容量超过MAX_ARRAY_SIZE时，```if (newCapacity - MAX_ARRAY_SIZE > 0)``` 进入该方法

   ```java
       private static int hugeCapacity(int minCapacity) {
           if (minCapacity < 0) // overflow
               throw new OutOfMemoryError();
           //对minCapacity和MAX_ARRAY_SIZE进行比较
           //若minCapacity大，将Integer.MAX_VALUE作为新数组的大小
           //若MAX_ARRAY_SIZE大，将MAX_ARRAY_SIZE作为新数组的大小
           //MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;
           return (minCapacity > MAX_ARRAY_SIZE) ?
               Integer.MAX_VALUE :
               MAX_ARRAY_SIZE;
       }
   ```

5. System.arraycopy() 和 Arrays.copyOf() 

   - ```java
     //System.arraycopy() 是一个native方法
         // 我们发现 arraycopy 是一个 native 方法,接下来我们解释一下各个参数的具体意义
         /**
         *   复制数组
         * @param src 源数组
         * @param srcPos 源数组中的起始位置
         * @param dest 目标数组
         * @param destPos 目标数组中的起始位置
         * @param length 要复制的数组元素的数量
         */
         public static native void arraycopy(Object src,  int  srcPos,
                                             Object dest, int destPos,
                                             int length);
     ```

     例子：

     ```java
     public class ArraycopyTest {
     
     	public static void main(String[] args) {
     		// TODO Auto-generated method stub
     		int[] a = new int[10];
     		a[0] = 0;
     		a[1] = 1;
     		a[2] = 2;
     		a[3] = 3;
     		System.arraycopy(a, 2, a, 3, 3);
     		a[2]=99;
     		for (int i = 0; i < a.length; i++) {
     			System.out.print(a[i] + " ");
     		}
     	}
     
     }
     //结果
     0 1 99 2 3 0 0 0 0 0
     ```

   - Arrays.copyOf() 方法

     ```java
         public static int[] copyOf(int[] original, int newLength) {
         	// 申请一个新的数组
             int[] copy = new int[newLength];
     	// 调用System.arraycopy,将源数组中的数据进行拷贝,并返回新的数组
             System.arraycopy(original, 0, copy, 0,
                              Math.min(original.length, newLength));
             return copy;
         }
     
     //场景
        /**
          以正确的顺序返回一个包含此列表中所有元素的数组（从第一个到最后一个元素）; 返回的数组的运行时类型是指定数组的运行时类型。
          */
         public Object[] toArray() {
         //elementData：要复制的数组；size：要复制的长度
             return Arrays.copyOf(elementData, size);
         }
     ```

     Arrays.copypf() ： 用来扩容，或者缩短

     ```java
     public class ArrayscopyOfTest {
     
     	public static void main(String[] args) {
     		int[] a = new int[3];
     		a[0] = 0;
     		a[1] = 1;
     		a[2] = 2;
     		int[] b = Arrays.copyOf(a, 10);
     		System.out.println("b.length"+b.length);
     	}
     }
     //结果： 10
     ```

6.  联系及区别
   
   - 看两者源代码可以发现 `copyOf()`内部实际调用了 `System.arraycopy()` 方法
   - arraycopy 更能实现自定义
   
7. **ensureCapacity** 方法
最好在向 `ArrayList` 添加大量元素之前用 `ensureCapacity` 方法，以减少增量重新分配的次数
   向 `ArrayList` 添加大量元素之前使用`ensureCapacity` 方法可以提升性能。不过，这个性能差距几乎可以忽略不计。而且，实际项目根本也不可能往 `ArrayList` 里面添加这么多元素

## 2. 核心源码解读

```java
package java.util;

import java.util.function.Consumer;
import java.util.function.Predicate;
import java.util.function.UnaryOperator;


public class ArrayList<E> extends AbstractList<E>
        implements List<E>, RandomAccess, Cloneable, java.io.Serializable
{
    private static final long serialVersionUID = 8683452581122892189L;

    /**
     * 默认初始容量大小
     */
    private static final int DEFAULT_CAPACITY = 10;

    /**
     * 空数组（用于空实例）。
     */
    private static final Object[] EMPTY_ELEMENTDATA = {};

     //用于默认大小空实例的共享空数组实例。
      //我们把它从EMPTY_ELEMENTDATA数组中区分出来，以知道在添加第一个元素时容量需要增加多少。
    private static final Object[] DEFAULTCAPACITY_EMPTY_ELEMENTDATA = {};

    /**
     * 保存ArrayList数据的数组
     */
    transient Object[] elementData; // non-private to simplify nested class access

    /**
     * ArrayList 所包含的元素个数
     */
    private int size;

    /**
     * 带初始容量参数的构造函数（用户可以在创建ArrayList对象时自己指定集合的初始大小）
     */
    public ArrayList(int initialCapacity) {
        if (initialCapacity > 0) {
            //如果传入的参数大于0，创建initialCapacity大小的数组
            this.elementData = new Object[initialCapacity];
        } else if (initialCapacity == 0) {
            //如果传入的参数等于0，创建空数组
            this.elementData = EMPTY_ELEMENTDATA;
        } else {
            //其他情况，抛出异常
            throw new IllegalArgumentException("Illegal Capacity: "+
                                               initialCapacity);
        }
    }

    /**
     *默认无参构造函数
     *DEFAULTCAPACITY_EMPTY_ELEMENTDATA 为0.初始化为10，也就是说初始其实是空数组 当添加第一个元素的时候数组容量才变成10
     */
    public ArrayList() {
        this.elementData = DEFAULTCAPACITY_EMPTY_ELEMENTDATA;
    }

    /**
     * 构造一个包含指定集合的元素的列表，按照它们由集合的迭代器返回的顺序。
     */
    public ArrayList(Collection<? extends E> c) {
        //将指定集合转换为数组
        elementData = c.toArray();
        //如果elementData数组的长度不为0
        if ((size = elementData.length) != 0) {
            // 如果elementData不是Object类型数据（c.toArray可能返回的不是Object类型的数组所以加上下面的语句用于判断）
            if (elementData.getClass() != Object[].class)
                //将原来不是Object类型的elementData数组的内容，赋值给新的Object类型的elementData数组
                elementData = Arrays.copyOf(elementData, size, Object[].class);
        } else {
            // 其他情况，用空数组代替
            this.elementData = EMPTY_ELEMENTDATA;
        }
    }

    /**
     * 修改这个ArrayList实例的容量是列表的当前大小。 应用程序可以使用此操作来最小化ArrayList实例的存储。
     */
    public void trimToSize() {
        modCount++;
        if (size < elementData.length) {
            elementData = (size == 0)
              ? EMPTY_ELEMENTDATA
              : Arrays.copyOf(elementData, size);
        }
    }
//下面是ArrayList的扩容机制
//ArrayList的扩容机制提高了性能，如果每次只扩充一个，
//那么频繁的插入会导致频繁的拷贝，降低性能，而ArrayList的扩容机制避免了这种情况。
    /**
     * 如有必要，增加此ArrayList实例的容量，以确保它至少能容纳元素的数量
     * @param   minCapacity   所需的最小容量
     */
    public void ensureCapacity(int minCapacity) {
        //如果是true，minExpand的值为0，如果是false,minExpand的值为10
        int minExpand = (elementData != DEFAULTCAPACITY_EMPTY_ELEMENTDATA)
            // any size if not default element table
            ? 0
            // larger than default for default empty table. It's already
            // supposed to be at default size.
            : DEFAULT_CAPACITY;
        //如果最小容量大于已有的最大容量
        if (minCapacity > minExpand) {
            ensureExplicitCapacity(minCapacity);
        }
    }
   //1.得到最小扩容量
   //2.通过最小容量扩容
    private void ensureCapacityInternal(int minCapacity) {
        if (elementData == DEFAULTCAPACITY_EMPTY_ELEMENTDATA) {
              // 获取“默认的容量”和“传入参数”两者之间的最大值
            minCapacity = Math.max(DEFAULT_CAPACITY, minCapacity);
        }

        ensureExplicitCapacity(minCapacity);
    }
  //判断是否需要扩容
    private void ensureExplicitCapacity(int minCapacity) {
        modCount++;

        // overflow-conscious code
        if (minCapacity - elementData.length > 0)
            //调用grow方法进行扩容，调用此方法代表已经开始扩容了
            grow(minCapacity);
    }

    /**
     * 要分配的最大数组大小
     */
    private static final int MAX_ARRAY_SIZE = Integer.MAX_VALUE - 8;

    /**
     * ArrayList扩容的核心方法。
     */
    private void grow(int minCapacity) {
        // oldCapacity为旧容量，newCapacity为新容量
        int oldCapacity = elementData.length;
        //将oldCapacity 右移一位，其效果相当于oldCapacity /2，
        //我们知道位运算的速度远远快于整除运算，整句运算式的结果就是将新容量更新为旧容量的1.5倍，
        int newCapacity = oldCapacity + (oldCapacity >> 1);
        //然后检查新容量是否大于最小需要容量，若还是小于最小需要容量，那么就把最小需要容量当作数组的新容量，
        if (newCapacity - minCapacity < 0)
            newCapacity = minCapacity;
        //再检查新容量是否超出了ArrayList所定义的最大容量，
        //若超出了，则调用hugeCapacity()来比较minCapacity和 MAX_ARRAY_SIZE，
        //如果minCapacity大于MAX_ARRAY_SIZE，则新容量则为Interger.MAX_VALUE，否则，新容量大小则为 MAX_ARRAY_SIZE。
        if (newCapacity - MAX_ARRAY_SIZE > 0)
            newCapacity = hugeCapacity(minCapacity);
        // minCapacity is usually close to size, so this is a win:
        elementData = Arrays.copyOf(elementData, newCapacity);
    }
    //比较minCapacity和 MAX_ARRAY_SIZE
    private static int hugeCapacity(int minCapacity) {
        if (minCapacity < 0) // overflow
            throw new OutOfMemoryError();
        return (minCapacity > MAX_ARRAY_SIZE) ?
            Integer.MAX_VALUE :
            MAX_ARRAY_SIZE;
    }

    /**
     *返回此列表中的元素数。
     */
    public int size() {
        return size;
    }

    /**
     * 如果此列表不包含元素，则返回 true 。
     */
    public boolean isEmpty() {
        //注意=和==的区别
        return size == 0;
    }

    /**
     * 如果此列表包含指定的元素，则返回true 。
     */
    public boolean contains(Object o) {
        //indexOf()方法：返回此列表中指定元素的首次出现的索引，如果此列表不包含此元素，则为-1
        return indexOf(o) >= 0;
    }

    /**
     *返回此列表中指定元素的首次出现的索引，如果此列表不包含此元素，则为-1
     */
    public int indexOf(Object o) {
        if (o == null) {
            for (int i = 0; i < size; i++)
                if (elementData[i]==null)
                    return i;
        } else {
            for (int i = 0; i < size; i++)
                //equals()方法比较
                if (o.equals(elementData[i]))
                    return i;
        }
        return -1;
    }

    /**
     * 返回此列表中指定元素的最后一次出现的索引，如果此列表不包含元素，则返回-1。.
     */
    public int lastIndexOf(Object o) {
        if (o == null) {
            for (int i = size-1; i >= 0; i--)
                if (elementData[i]==null)
                    return i;
        } else {
            for (int i = size-1; i >= 0; i--)
                if (o.equals(elementData[i]))
                    return i;
        }
        return -1;
    }

    /**
     * 返回此ArrayList实例的浅拷贝。 （元素本身不被复制。）
     */
    public Object clone() {
        try {
            ArrayList<?> v = (ArrayList<?>) super.clone();
            //Arrays.copyOf功能是实现数组的复制，返回复制后的数组。参数是被复制的数组和复制的长度
            v.elementData = Arrays.copyOf(elementData, size);
            v.modCount = 0;
            return v;
        } catch (CloneNotSupportedException e) {
            // 这不应该发生，因为我们是可以克隆的
            throw new InternalError(e);
        }
    }

    /**
     *以正确的顺序（从第一个到最后一个元素）返回一个包含此列表中所有元素的数组。
     *返回的数组将是“安全的”，因为该列表不保留对它的引用。 （换句话说，这个方法必须分配一个新的数组）。
     *因此，调用者可以自由地修改返回的数组。 此方法充当基于阵列和基于集合的API之间的桥梁。
     */
    public Object[] toArray() {
        return Arrays.copyOf(elementData, size);
    }

    /**
     * 以正确的顺序返回一个包含此列表中所有元素的数组（从第一个到最后一个元素）;
     *返回的数组的运行时类型是指定数组的运行时类型。 如果列表适合指定的数组，则返回其中。
     *否则，将为指定数组的运行时类型和此列表的大小分配一个新数组。
     *如果列表适用于指定的数组，其余空间（即数组的列表数量多于此元素），则紧跟在集合结束后的数组中的元素设置为null 。
     *（这仅在调用者知道列表不包含任何空元素的情况下才能确定列表的长度。）
     */
    @SuppressWarnings("unchecked")
    public <T> T[] toArray(T[] a) {
        if (a.length < size)
            // 新建一个运行时类型的数组，但是ArrayList数组的内容
            return (T[]) Arrays.copyOf(elementData, size, a.getClass());
            //调用System提供的arraycopy()方法实现数组之间的复制
        System.arraycopy(elementData, 0, a, 0, size);
        if (a.length > size)
            a[size] = null;
        return a;
    }

    // Positional Access Operations

    @SuppressWarnings("unchecked")
    E elementData(int index) {
        return (E) elementData[index];
    }

    /**
     * 返回此列表中指定位置的元素。
     */
    public E get(int index) {
        rangeCheck(index);

        return elementData(index);
    }

    /**
     * 用指定的元素替换此列表中指定位置的元素。
     */
    public E set(int index, E element) {
        //对index进行界限检查
        rangeCheck(index);

        E oldValue = elementData(index);
        elementData[index] = element;
        //返回原来在这个位置的元素
        return oldValue;
    }

    /**
     * 将指定的元素追加到此列表的末尾。
     */
    public boolean add(E e) {
        ensureCapacityInternal(size + 1);  // Increments modCount!!
        //这里看到ArrayList添加元素的实质就相当于为数组赋值
        elementData[size++] = e;
        return true;
    }

    /**
     * 在此列表中的指定位置插入指定的元素。
     *先调用 rangeCheckForAdd 对index进行界限检查；然后调用 ensureCapacityInternal 方法保证capacity足够大；
     *再将从index开始之后的所有成员后移一个位置；将element插入index位置；最后size加1。
     */
    public void add(int index, E element) {
        rangeCheckForAdd(index);

        ensureCapacityInternal(size + 1);  // Increments modCount!!
        //arraycopy()这个实现数组之间复制的方法一定要看一下，下面就用到了arraycopy()方法实现数组自己复制自己
        System.arraycopy(elementData, index, elementData, index + 1,
                         size - index);
        elementData[index] = element;
        size++;
    }

    /**
     * 删除该列表中指定位置的元素。 将任何后续元素移动到左侧（从其索引中减去一个元素）。
     */
    public E remove(int index) {
        rangeCheck(index);

        modCount++;
        E oldValue = elementData(index);

        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // clear to let GC do its work
      //从列表中删除的元素
        return oldValue;
    }

    /**
     * 从列表中删除指定元素的第一个出现（如果存在）。 如果列表不包含该元素，则它不会更改。
     *返回true，如果此列表包含指定的元素
     */
    public boolean remove(Object o) {
        if (o == null) {
            for (int index = 0; index < size; index++)
                if (elementData[index] == null) {
                    fastRemove(index);
                    return true;
                }
        } else {
            for (int index = 0; index < size; index++)
                if (o.equals(elementData[index])) {
                    fastRemove(index);
                    return true;
                }
        }
        return false;
    }

    /*
     * Private remove method that skips bounds checking and does not
     * return the value removed.
     */
    private void fastRemove(int index) {
        modCount++;
        int numMoved = size - index - 1;
        if (numMoved > 0)
            System.arraycopy(elementData, index+1, elementData, index,
                             numMoved);
        elementData[--size] = null; // clear to let GC do its work
    }

    /**
     * 从列表中删除所有元素。
     */
    public void clear() {
        modCount++;

        // 把数组中所有的元素的值设为null
        for (int i = 0; i < size; i++)
            elementData[i] = null;

        size = 0;
    }

    /**
     * 按指定集合的Iterator返回的顺序将指定集合中的所有元素追加到此列表的末尾。
     */
    public boolean addAll(Collection<? extends E> c) {
        Object[] a = c.toArray();
        int numNew = a.length;
        ensureCapacityInternal(size + numNew);  // Increments modCount
        System.arraycopy(a, 0, elementData, size, numNew);
        size += numNew;
        return numNew != 0;
    }

    /**
     * 将指定集合中的所有元素插入到此列表中，从指定的位置开始。
     */
    public boolean addAll(int index, Collection<? extends E> c) {
        rangeCheckForAdd(index);

        Object[] a = c.toArray();
        int numNew = a.length;
        ensureCapacityInternal(size + numNew);  // Increments modCount

        int numMoved = size - index;
        if (numMoved > 0)
            System.arraycopy(elementData, index, elementData, index + numNew,
                             numMoved);

        System.arraycopy(a, 0, elementData, index, numNew);
        size += numNew;
        return numNew != 0;
    }

    /**
     * 从此列表中删除所有索引为fromIndex （含）和toIndex之间的元素。
     *将任何后续元素移动到左侧（减少其索引）。
     */
    protected void removeRange(int fromIndex, int toIndex) {
        modCount++;
        int numMoved = size - toIndex;
        System.arraycopy(elementData, toIndex, elementData, fromIndex,
                         numMoved);

        // clear to let GC do its work
        int newSize = size - (toIndex-fromIndex);
        for (int i = newSize; i < size; i++) {
            elementData[i] = null;
        }
        size = newSize;
    }

    /**
     * 检查给定的索引是否在范围内。
     */
    private void rangeCheck(int index) {
        if (index >= size)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    /**
     * add和addAll使用的rangeCheck的一个版本
     */
    private void rangeCheckForAdd(int index) {
        if (index > size || index < 0)
            throw new IndexOutOfBoundsException(outOfBoundsMsg(index));
    }

    /**
     * 返回IndexOutOfBoundsException细节信息
     */
    private String outOfBoundsMsg(int index) {
        return "Index: "+index+", Size: "+size;
    }

    /**
     * 从此列表中删除指定集合中包含的所有元素。
     */
    public boolean removeAll(Collection<?> c) {
        Objects.requireNonNull(c);
        //如果此列表被修改则返回true
        return batchRemove(c, false);
    }

    /**
     * 仅保留此列表中包含在指定集合中的元素。
     *换句话说，从此列表中删除其中不包含在指定集合中的所有元素。
     */
    public boolean retainAll(Collection<?> c) {
        Objects.requireNonNull(c);
        return batchRemove(c, true);
    }


    /**
     * 从列表中的指定位置开始，返回列表中的元素（按正确顺序）的列表迭代器。
     *指定的索引表示初始调用将返回的第一个元素为next 。 初始调用previous将返回指定索引减1的元素。
     *返回的列表迭代器是fail-fast 。
     */
    public ListIterator<E> listIterator(int index) {
        if (index < 0 || index > size)
            throw new IndexOutOfBoundsException("Index: "+index);
        return new ListItr(index);
    }

    /**
     *返回列表中的列表迭代器（按适当的顺序）。
     *返回的列表迭代器是fail-fast 。
     */
    public ListIterator<E> listIterator() {
        return new ListItr(0);
    }

    /**
     *以正确的顺序返回该列表中的元素的迭代器。
     *返回的迭代器是fail-fast 。
     */
    public Iterator<E> iterator() {
        return new Itr();
    }
```


